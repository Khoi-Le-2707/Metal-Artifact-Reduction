#!/usr/bin/env python3
"""
Synthesizes phantom based on LEAP: 
https://github.com/LLNL/LEAP/blob/main/demo_leapctype/d30_MAR_and_sinogram_replacement.py, 
generates sinogram + metal trace, linear interpolation (SLI) and FBP reconstruction (LI_CT),
writes everything to a DeepLesion-compatible .h5 file
"""

import os, h5py, cv2
import numpy as np
from leapctype import *

# ======================================================================
# 1)  General parameters
# ======================================================================
OUT_DIR   = "./my_test_data/test_640geo"
OUT_H5    = os.path.join(OUT_DIR, "0.h5")

IMG_HW    = 416            # InDuDoNet image size (416×416)
SINO_HW   = 640            # InDuDoNet sinogram size (640×640)

HU_MIN, HU_MAX = -1000., 2000.   # Normalization window


# -----------------------------------------------------------
# 2)   LEAP scene + data simulation (taken from d30_MAR_and_sinogram_replacement.py)
# -----------------------------------------------------------
leapct = tomographicModels()
cols, rows     = 512, 1
pix            = 0.65*512/cols
angles         = 2*2*int(360*cols/1024)        # 720 Views
leapct.set_conebeam(angles, rows, cols, pix, pix,
                    0.5*(rows-1), 0.5*(cols-1),
                    leapct.setAngleArray(angles, 360.0),
                    1100, 1400)
leapct.set_default_volume()

g_art = leapct.allocateProjections()        # (angles, rows, cols)
f_art = leapct.allocateVolume()             # (nz, ny, nx)
   

# ⇢ FORBILD head + metal (as in the demo script)
leapct.set_FORBILD()
leapct.addObject(None, 0, 10.0*np.array([-6.00000, 6.039200, 0.0]), 10.0*0.4*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([-6.00000, -6.039200, 0.0]), 10.0*0.4*np.array([1.0, 1.0, 1.0]), 1.2140)
leapct.addObject(None, 0, 10.0*np.array([6.40000, -6.039200, 0.0]), 10.0*0.05*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([5.80000, -6.4000, 0.0]), 10.0*0.1*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([6.30000, -5.6200, 0.0]), 10.0*0.05*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([5.90000, -6.039200, 0.0]), 10.0*0.05*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([6.00000, -5.739200, 0.0]), 10.0*0.1*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([6.50000, -6.5200, 0.0]), 10.0*0.1*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([5.70000, -5.29200, 0.0]), 10.0*0.05*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([5.60000, -5.69200, 0.0]), 10.0*0.05*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([5.40000, -6.2200, 0.0]), 10.0*0.05*np.array([1.0, 1.0, 1.0]), 0.8106)
leapct.addObject(None, 0, 10.0*np.array([5.20000, -6.4200, 0.0]), 10.0*0.05*np.array([1.0, 1.0, 1.0]), 0.8106)

# -----------  Ideal projections------------------------------------
leapct.rayTrace(g_art, oversampling=3)

# -----------   Save Ground Truth as .png -----------------------

# ori_f = leapct.allocate_volume()
# leapct.FBP(g_art,ori_f)
# # plt.subplot(1,2,2)
# import matplotlib.image
# matplotlib.image.imsave("Ground_truth.png", np.squeeze(ori_f),cmap="gray", vmin=0.0, vmax=0.04)


# -----------   Photonstarvation / metal artifact  ----------------------
I0 = 1e5
t  = np.random.poisson(I0*np.exp(-g_art))
t[t <= 1.] = 1.
g_art[:] = -np.log(t/I0)

# -----------   FBP reconstruction with artifacts -----------------------
leapct.FBP(g_art, f_art)
leapct.BlurFilter(f_art, 2.0)
f_art_copy = f_art.copy()                    


# ----------------------------------------------------------------------
# 3)  Metal-Trace-Mask
# ----------------------------------------------------------------------
metal_vol = (f_art > 0.06).astype(np.float32)
W = leapct.allocateProjections()
leapct.project(W, metal_vol)

metal_trace = (np.squeeze(W) > 0).astype(np.float32)
# metal_trace = metal_trace.T      # (det, angle)  – InDuDoNet-convention


# ----------------------------------------------------------------------
# 4)  Sinogram-Replacement  →  corrected g_sr & FBP → f_sr
# ----------------------------------------------------------------------
# 4.1  RWLS Prior for Replacement
Ww = np.exp(-W)
f_prior = leapct.allocateVolume(); f_prior[:] = 0.
filters = filterSequence(1e4); filters.append(TV(leapct, delta=0.01/100., p=1.2))
leapct.RWLS(g_art, f_prior, 50, filters, Ww, 'SQS')
leapct.RWLS(g_art, f_prior, 100, filters, Ww)

# 4.2  Prior-Sinogramm
prior = g_art.copy()
leapct.project(prior, f_prior)

# Create a C-contiguous copy with the correct dtype
metal_trace_ct = np.ascontiguousarray(metal_trace, dtype=np.float32)
# 4.3  Sinogram-Replacement  (writes IN PLACE in g_art)
leapct.sinogram_replacement(g_art, prior, metal_trace_ct)   # uses the same shape

g_sr = g_art.copy()      # save corrected sinogram

# 4.4  FBP from g_sr
f_sr = leapct.allocateVolume()
leapct.FBP(g_sr, f_sr)

# 4.5  Copy back metal voxels (as in the demo)
f_sr[(f_art > 0.06)] = f_art_copy[(f_art > 0.06)]


# Uncomment this if you want to visualize any sinogram or reconstructed image

# import matplotlib
# matplotlib.use('TkAgg')
# import matplotlib.pyplot as plt
# plt.figure(figsize=(6,4))
# plt.subplot(1,2,1)
# plt.title('g (Artefakt-Sinogramm)')
# plt.imshow(np.squeeze(g_sr), cmap='gray', aspect='auto')
# plt.xlabel('Detektor-Spalte')
# plt.ylabel('View-Index')

# plt.subplot(1,2,2)
# plt.title('f (Artefakt-Rekonstruktion)')
# plt.imshow(np.squeeze(f_sr), cmap='gray', vmin=0.0, vmax=0.04)
# plt.xlabel('x')
# plt.ylabel('y')
# plt.tight_layout()

# plt.show()


# ----------------------------------------------------------------------
# 5)  About DeepLesion Shapes & Normalization
# ----------------------------------------------------------------------
def to_ct_norm(vol_slice):
    hu  = vol_slice*3000. - 1000.
    return np.clip((hu - HU_MIN)/(HU_MAX-HU_MIN), 0., 1.).astype(np.float32)

# Extract middle layer
mid = f_art_copy.shape[0]//2
ma_CT = to_ct_norm(cv2.resize(np.squeeze(f_art_copy[mid]),
                              (IMG_HW, IMG_HW), cv2.INTER_LINEAR))
LI_CT = to_ct_norm(cv2.resize(np.squeeze(f_sr[mid]),
                              (IMG_HW, IMG_HW), cv2.INTER_LINEAR))

def prep_sino(sino):
    s = cv2.resize(np.squeeze(sino).astype(np.float32),
                   (SINO_HW+1, SINO_HW+1),
                   interpolation=cv2.INTER_LINEAR)[:SINO_HW+1, :SINO_HW]
    return s.T          # (det, angle)

ma_sino = prep_sino(g_art)
LI_sino = prep_sino(g_sr)


# ----------------------------------------------------------------------
# 6)  Scaling to correct sizes for .h5 file for InDuDoNet
# ----------------------------------------------------------------------
metal_trace = cv2.resize(metal_trace,
                         (SINO_HW+1, SINO_HW+1),
                         interpolation=cv2.INTER_NEAREST)[:SINO_HW, :SINO_HW+1]
print(metal_trace.shape)
print(LI_sino.shape)
print(ma_sino.shape)


# ----------------------------------------------------------------------
# 7)  write in .h5 
# ----------------------------------------------------------------------
os.makedirs(OUT_DIR, exist_ok=True)
with h5py.File(OUT_H5, "w") as h5:
    h5.create_dataset("ma_CT",         data=ma_CT)
    h5.create_dataset("ma_sinogram",   data=ma_sino)
    h5.create_dataset("LI_CT",         data=LI_CT)
    h5.create_dataset("LI_sinogram",   data=LI_sino)
    h5.create_dataset("metal_trace",   data=metal_trace)
    h5.create_dataset("image",         data=np.zeros_like(ma_CT))  # Dummy-GT
    h5.create_dataset("art",           data=ma_CT)                 # Alias

print("✅  .h5 written:", OUT_H5)


# ---------- Dummy mask file (optional for other scripts) ----------
# Save the central disk of the metal mask
mask_bool = (metal_vol[mid] > 0).astype(np.uint8)  # (512×512)
mask_save = mask_bool[np.newaxis, ...]             # (1,512,512)
np.save(os.path.join(OUT_DIR, "..", "testmask.npy"), mask_save)
print("✅ Dummy mask saved: testmask.npy")

# ---------- Test list for InDuDoNet ----------
list_path = os.path.join(OUT_DIR, "..", "test_640geo_dir.txt")
with open(list_path, "w") as f:
    f.write("0.h5\n")
print("✅ test_640geo_dir.txt written.")

# [Interpolation and NMAR Algorithm Using MATLAB](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0227656)

> ⚠️ **Warning**  
> Make sure the MATLAB GUI runs correctly before proceeding.

First, follow the instructions in the `README.md` file located in the [Original_Code](./Original_Code/Readme.txt) folder.

In this repository, a sinogram with dimensions **10 × 420 × 720** is used as test data. The size **420 × 720** represents the dimensions of a single sinogram slice, and `10` might indicate the number of adjacent slices used (this is not clearly documented).

Our test data comes from the [AAPM Grand Challenge](https://www.aapm.org/GrandChallenge/CT-MAR/) — a source of real-world CT data with metal artifacts.  
(Direct download: https://rpi.app.box.com/s/7p8tkqj5ewhtdad2h8kx975i9qg6b7a4/folder/230223517638)  
This dataset contains sinograms of size **900 × 1000**.

---

## 💡 Two Options to Use *Interpolation* with our test data:

1. **Resize**: Shrink our sinogram from **900 × 1000** to **420 × 720**.
2. **Parameter Tuning**: Modify [`parameter.m`](./Original_Code/parameter.m) to accept a **900 × 1000** sinogram as input.

---

## Option 1 – Resizing

If we shrink the sinogram, the reconstructed image becomes distorted.  
→ This is **not feasible** for our use case. If you can adjust the sinogram size directly during scanning (via hardware configuration), it might work correctly.

---

## Option 2 – Parameter Modification

Run `Main.m` in the [Modified_Code](./Modified_Code/) folder. You will notice that the [reconstructed image](./Modified_Code/Bilder/reconstructed_image_using_FDK_in_this_repo.png) using the FDK function from this repo looks incorrect — it appears as if multiple slices are overlapping and rotated.

There are two possible reasons we suspect:

1. Our data may originate from a **fan beam CT**, whereas the algorithm is designed for a **cone beam CT**.
2. We don’t know the **exact parameters** in [`parameter.m`](./Original_Code/parameter.m), such as:  
   - Distance from the X-ray source to the object  
   - Distance from the object to the detector  
   - Offset between the detector and the object, etc. 

We experimented with several values and manually tuned the parameters for hours — unfortunately, it didn't resolve the issue.


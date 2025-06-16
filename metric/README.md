# CT Image Quality Evaluation Script

This folder contains a MATLAB script (statistic.m) to evaluate the quality of MAR images using **SSIM** (Structural Similarity Index) and **PSNR** (Peak Signal-to-Noise Ratio). The script compares the MAR image against a ground truth image while ignoring metals defined by metal mask. The output is two bar charts for each metric that compare different MAR methods defined in the array `model_list`.

The functions `ssim_SDL.m` and `psnr_SDL.m` used in this repository are adapted from:

📎 [OSCNet](../SynDeepLesion_hongwang01/OSCNet)

📝 Original author for SSIM: [Zhou Wang](https://www.ece.uwaterloo.ca/~z70wang/)  
📄 License: See header in `ssim_SDL.m`  

---

## Requirements

- MATLAB (tested with R2024b)
- Required Images:
    - 'ground_truth.png' - The clean reference CT image
    - 'metal_mask.png' - Binary mask image where metals are located (1 = metal)
- Images from MAR methods you want to compare

--- 

## How to use

Make sure the metal artifact reduced images are all in the same folder and the picture names are defined in `model_list`.
```matlab
model_list = ["InDuDoNet", "InDuDoNet+", "OSCNet", "ACDNet", "DICDNet", "SR"];
```


### 📐 Image Size & Resizing

All images in this evaluation are expected to have a resolution of **512 × 512 pixels**, which is the default size of the ground truth (`ground_truth.png`) and the metal mask (`metal_mask.png`).  
To ensure a fair and pixel-wise comparison, all model outputs must match this resolution.

By default, the script automatically resizes each model image to `(512, 512)` **unless** it matches a specific name (e.g., `"SR"`), which is assumed to already be in the correct format:

```matlab
if model_list(i) ~= "SR"
    mar_img = imresize(mar_img, [512 512]);
end
```
If you want to use a different resolution for the ground truth, make sure all other images (mask and outputs) match that new size, and adjust the resizing accordingly.

---
Now, by running the script, you should see two side-by-side bar plots
- Left: SSIM (range 0-1)
- Right: PSNR (in dB)

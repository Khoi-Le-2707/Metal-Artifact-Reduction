# MAR Deep Learning Algorithms from [Hong Wang](https://github.com/hongwang01/SynDeepLesion/tree/main)

If you want to test any of these five algorithms, please refer to the [InDuDoNet dependencies](https://github.com/hongwang01/InDuDoNet).

> 💡 **Tip**  
> Use a Conda environment or a Python virtual environment to create a self-contained, isolated space where you can install specific versions of software packages.

After following those instructions, if you encounter any problems installing dependencies or running the tests, follow the steps below to resolve them and then test with your own data.

## Possible Problems While Installing Dependencies

This repository was tested under the following system configuration:

- **Python**: 3.11.11  
- **PyTorch**: 2.7.0 
- **CUDA**: 12  
- **GPU**: NVIDIA RTX 500 Ada Generation Laptop GPU

We set up a Conda environment:

```bash
conda create -n indudonet-env python=3.11.11
conda activate indudonet-env

conda install -c conda-forge odl
conda install -c astra-toolbox -c nvidia astra-toolbox
pip install -r requirement_for_higher_version_torch.txt
```

Even the `requirement_for_higher\ version_torch.txt` is not up-to-date anymore, that's why we removes all version bindings (==) from the file with:
```bash
sed 's/==.*//' requirement_for_higher\ version_torch.txt > req_clean.txt
pip install -r req_clean.tx
```
Alternatively, install compatible versions of ODL and Astra toolbox, downgrade to Python 3.9.18, then run `pip install -r requirement_for_higher\ version torch.txt`. 

Finally, install nibabel with `pip install nibabel`.

## Testing with our own data `phantom_to_h5.py`
The `.h5` file serves as test data. You can convert either your own real sinograms and reconstructed images with metal artifacts or artificially generated images into `.h5` files.

Besides the benchmark dataset from DeepLesion in InDuDoNet, we also found this [AAPM Grand Challenge](https://www.aapm.org/GrandChallenge/CT-MAR/) as a source of real-world test data with metal artifacts.

(Direct link: https://rpi.app.box.com/s/7p8tkqj5ewhtdad2h8kx975i9qg6b7a4/folder/230223517638)

> These are raw `(.raw)` files. You can open them with a Python script or [Fiji ImageJ](https://imagej.net/software/fiji/downloads). FIn Fiji, enable `Little Endian (Standard) byte order` box and then use `Image → Adjust → Brightness/Contrast`.

In `phantom_to_h5.py`, we take the LEAP-generated phantom and sinogram (see [LEAP demo](https://github.com/LLNL/LEAP/blob/main/demo_leapctype/d30_MAR_and_sinogram_replacement.py)) and convert them into a DeepLesion-compatible ``.h5`` file for our SynDeepLesion algorithms.

## A Brief Explanation of `test_deeplesion.py` (from all 5 algorithms)

These are all the variables that `test_deeplesion.py` expects in the ``.h5`` file: 
| **Variable** | **Meaning**                     | **Brief Description**                                                                                                                                       |
|--------------|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Xma**       | Metal Artifact CT Image          | The reconstructed CT image **with strong metal artifacts**, usually obtained directly from FBP.                                                             |
| **XLI**       | Linearly Interpolated CT         | The CT image after **linear interpolation** over metal-affected regions – a basic attempt at artifact reduction.                                            |
| **Xgt**       | Ground Truth CT Image            | The **artifact-free reference image** (available only for synthetic or simulated data). Used for comparison or training.                                    |
| **M**         | Metal Mask (Image Domain)        | A binary mask in the image domain (size: 416×416) where **metal is visible in the slice** (1 = metal, 0 = background).                                     |
| **Sma**       | Sinogram with Metal Artifacts    | The measured **sinogram containing artifacts**, directly from forward projection of the metal-affected CT image.                                            |
| **SLI**       | Interpolated Sinogram            | The sinogram after **linear interpolation** over metal traces – similar to `XLI`, but in the sinogram domain.                                              |
| **Sgt**       | Ground Truth Sinogram            | The **artifact-free reference sinogram**, obtained by forward-projecting `Xgt`. Only available in simulation settings.                                      |
| **Tr**        | Trace Mask (Sinogram Domain)     | A binary **sinogram mask** indicating **where rays passed through metal** (1 = unaffected, 0 = blocked by metal).                  |

As we can see below, *Dual-Domain* methods require all of these variables, whereas *Image-Domain* methods only need `Xma, X, XLI, M` as inputs:

----------
| Method | Domain | Original Link |
|---|---|---|
| InDuDoNet (MICCAI2021) | Dual-Domain | [https://github.com/hongwang01/InDuDoNet](https://github.com/hongwang01/InDuDoNet)|
| InDuDoNet+ (MedIA2023) | Dual-Domain | [https://github.com/hongwang01/InDuDoNet_plus](https://github.com/hongwang01/InDuDoNet_plus)|
| DICDNet (TMI2021)| Image-Domain | [https://github.com/hongwang01/DICDNet](https://github.com/hongwang01/DICDNet)|
| ACDNet (IJCAI2022) | Image-Domain | [https://github.com/hongwang01/ACDNet](https://github.com/hongwang01/ACDNet)|
| OSCNet (MICCAI2022, TMI2023) | Image-Domain | [https://github.com/hongwang01/OSCNet](https://github.com/hongwang01/OSCNet)|
----------

> ℹ️ **Note**  
> Ground truth is not required by the MAR algorithms—it’s used only for comparison. We include a dummy `Xgt` to ensure the code runs without errors.

----------
**How to Generate Interpolated Data** 
> ℹ️ **Note**  
> There is no instruction on the official GitHub repo on how to obtain interpolated images, so this is just a temporary solution we found, which may not be correct. Please find a better interpolation method if feasible.

If you have your own CT machine, know the hardware parameters, and can adjust the image parameters as needed, then you can create **interpolated sinograms and CT images** by following this [Interpolation Repo in Matlab](../Interpolation_NMAR/).

However, we do not know the parameters of our hardware and also do not have access to it. Therefore, we simply assume that an interpolated image is a visually improved image with reduced metal artifacts. Our [LEAP_sinogram_replacement](../LEAP_sinogram_replacement/) is also capable of reducing metal artifacts.

→ We use the sinogram and CT image after `LEAP_sinogram_replacement` as input in place of **XLI** and **SLI**.

## Testing
Run `phantom_to_h5.py`, then test using the corresponding `pretrained_model` from the respective algorithm. For example, to test ***InDuDoNet***:
```bash
conda activate indudonet-env
cd ~/Metal-Artifact-Reduction/SynDeepLesion_hongwang01
python3 phantom_to_h5.py
```
> 📌 **Important**  
> For demo testing, we only provide one testing image as "my_test_data/test_640geo/0.h5".
>
> You need to ensure this part of code in `test_deeplesion.py` has always 1 for-loop (not 10 or 200):
>```python 
>   for imag_idx in range(1): # for demo
>        print(imag_idx)
>        for mask_idx in range(1):  #instead of 10
>```
> In ***InDuDoNet*** this code snippet begins at line 114. For other algorithms, locate and adjust this part in the `main` function as well.


Then run: 
```bash
cd InDuDoNet    # Make sure you're inside the correct algorithm folder
CUDA_VISIBLE_DEVICES=0 python test_deeplesion.py --data_path "../my_test_data/"  --model_dir "pretrained_model/InDuDoNet_latest.pt" --save_path "my_results/"
# For other algorithms just modify this test-command respectively the instruction on each official Github Repo
```
> ⚠️ **Warning**  
>1. The result may look poor for several reasons — one is that `testmask.npy` is randomly generated since we don’t know the correct way to produce it.
>2. For ***InDuDoNet_plus***, run:
>`CUDA_VISIBLE_DEVICES=0 python test_deeplesion.py --data_path "../my_test_data/" --model_dir "pretrained_model/InDuDoNet+_latest.pt" --save_path "my_results/"`
>instead of the command in the original GitHub README: `--model_dir "pretrained_model/`.
>3. If you want to view *ground truth* for comparison, uncomment lines 60–66 in `phantom_to_h5.py`.
>4. Results from *Image-Domain* algorithms may look better—not because *Dual-Domain* algorithms are worse, but because *Image-Domain* methods do not rely on the sinogram as input, whereas *Dual-Domain* methods do. Our sinogram, although acceptable as input (we verified it visually), does not look as good after processing with *Dual-Domain* algorithms, which may affect the output quality.

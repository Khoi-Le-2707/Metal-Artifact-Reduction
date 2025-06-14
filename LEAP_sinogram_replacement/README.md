# [MAR_and_sinogram_replacement from LEAP](https://github.com/LLNL/LEAP/blob/main/demo_leapctype/d30_MAR_and_sinogram_replacement.py)

> 💡 **Tip**  
> Use a Conda environment or a Python virtual environment to create a self-contained, isolated space where you can install specific versions of software packages.

First, follow the **Installation and Usage** section from the [official LEAP repository](https://github.com/LLNL/LEAP/tree/main).  
If you encounter any issues, refer to the [`Possible Problems While Installing Dependencies`](../SynDeepLesion_hongwang01/README.md) section in the [**SynDeepLesion_hongwang01**](../SynDeepLesion_hongwang01/) project.

---

## ❗ Common Error

While testing, we encountered the following error:

`OSError: ...libstdc++.so.6: version GLIBCXX_3.4.32' not found (required by .../libleapct.so)`.

This means that your current version of `libstdc++.so.6` is too old to run the native library `libleapct.so` used in LEAP.

→ To fix this, update `libstdc++` in your Conda environment:

```bash
conda install -c conda-forge libstdcxx-ng
```

## ✅ Run the Demo
Once everything is set up, run:
```bash
python3 LEAP/demo_leapctype/d30_MAR_and_sinogram_replacement.py
```

## Test with Our Own Data

Our test data comes from the [AAPM Grand Challenge](https://www.aapm.org/GrandChallenge/CT-MAR/) — a source of real-world CT data with metal artifacts.  
(Direct download: https://rpi.app.box.com/s/7p8tkqj5ewhtdad2h8kx975i9qg6b7a4/folder/230223517638)

We successfully got the test data in `d30_MAR_and_sinogram_replacement.py` to run. However, since that test data is only artificially generated, we were unable to figure out how to adapt the code to correctly apply the ***sinogram_replacement*** function to our raw (`.raw`) files from the [AAPM Grand Challenge](https://www.aapm.org/GrandChallenge/CT-MAR/).

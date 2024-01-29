# Patrick's Automated Segmentation-to-Analysis (PASTA) Pipeline
This pipeline will segment individual cells in a 2D image using Cellpose, utilize this segmentation to create masks, measure the mean fluorescence in each mask in the original .tif or .png files, and optionally output a plot of mean fluorescence intensity of those masks based on user-specified groups. Additionally, individual sections of this script can be run individually, assuming that all required files are present for that section to run. Individual sections can be run using using the `--cellpose-only`, `--fiji-only`, and `--visualization-only` flags. More information about Cellpose can be found at [https://www.cellpose.org](https://www.cellpose.org).

Note: This pipeline was written and tested on a Mac and it is likely that it won't run on other operating systems. If you want to help convert it to work on other operating systems, let me know!

## Download:
```
cd /path/to/download/directory
wget https://github.com/phorve/PASTA/archive/master.zip && unzip master.zip && rm master.zip
```

## Dependencies
* [**CellPose 2.0**](https://github.com/MouseLand/cellpose) (full instructions for installation can be found on their website)
    1. Download and install [miniconda](https://docs.conda.io/projects/miniconda/en/latest/)
        * Optional: Test your installation by running `conda list`. If conda has been installed currently, a list of installed packages appears. 
    2.	Open a terminal window
    3.	Run the following code: `conda create --name cellpose python=3.8`. This will create an isolated environment within your computer that will always the same for the program to run.
    4.	Now open this newly installed environment using the following code: `conda activate cellpose`
    5.	Install CellPose using the following code: `python -m pip install cellpose[gui]`
* [**FIJI**](https://fiji.sc/)
* [**R**](https://www.r-project.org/)
* [**Homebrew**](https://brew.sh/)
    * Note: This can be checked for and installed by using the `--check-dependencies` flag
* [**Zenity**](https://help.gnome.org/users/zenity/stable/)
    * Note: This can be checked for and installed by using the `--check-dependencies` flag

## Using PASTA
### Step-by-step demo
PASTA comes with a small folder of images that can be used to test the installation of the software and make sure everything is working correctly. This folder is called "test" and is located inside of the parent PASTA directory. These images are from the [CellPose testing data](https://www.cellpose.org/dataset).

PASTA pipeline is expecting a folder named "Original_Images" inside of a parent directory (see example below).
```
./test
├── Original_Images
    ├── 000_img_group1.png
    ├── 001_img_group1.png
    ├── 002_img_group1.png
    ├── 003_img_group2.png
    ├── 004_img_group2.png
    └── 005_img_group2.png
```
To run PASTA, run the following code below. The only user input that should be required is for you to select the parent directory that contains the "Original_Images" directory. So for the example below, you would select the "test" folder. 
```
cd ~/PASTA-main
bash PASTA.sh --full-pipeline --cellpose-model=cyto --group=group1 --group=group2 --check-dependencies
```  
After running the full pipeline (this took 331.48 seconds on a 2021 Apple M1 Macbook Pro with 16GB of RAM), the folder structure should now be the following: 
```
./test
├── Cellpose_npy
│   ├── 000_img_group1_seg.npy
│   ├── 001_img_group1_seg.npy
│   ├── 002_img_group1_seg.npy
│   ├── 003_img_group2_seg.npy
│   ├── 004_img_group2_seg.npy
│   └── 005_img_group2_seg.npy
├── Measurements
│   ├── 000_img_group1.png_Results.csv
│   ├── 001_img_group1.png_Results.csv
│   ├── 002_img_group1.png_Results.csv
│   ├── 003_img_group2.png_Results.csv
│   ├── 004_img_group2.png_Results.csv
│   ├── 005_img_group2.png_Results.csv
│   ├── CombinedData.csv
├── Original_Images
│   ├── 000_img_group1.png
│   ├── 001_img_group1.png
│   ├── 002_img_group1.png
│   ├── 003_img_group2.png
│   ├── 004_img_group2.png
│   └── 005_img_group2.png
├── Overlays
│   ├── 000_img_group1.png_ROIs_Overlay.png
│   ├── 001_img_group1.png_ROIs_Overlay.png
│   ├── 002_img_group1.png_ROIs_Overlay.png
│   ├── 003_img_group2.png_ROIs_Overlay.png
│   ├── 004_img_group2.png_ROIs_Overlay.png
│   └── 005_img_group2.png_ROIs_Overlay.png
├── PNG_masks
│   ├── 000_img_group1_cp_masks.png
│   ├── 001_img_group1_cp_masks.png
│   ├── 002_img_group1_cp_masks.png
│   ├── 003_img_group2_cp_masks.png
│   ├── 004_img_group2_cp_masks.png
│   └── 005_img_group2_cp_masks.png
├── TIF_masks
│   ├── 000_img_group1_cp_masks.tif
│   ├── 001_img_group1_cp_masks.tif
│   ├── 002_img_group1_cp_masks.tif
│   ├── 003_img_group2_cp_masks.tif
│   ├── 004_img_group2_cp_masks.tif
│   └── 005_img_group2_cp_masks.tif
├── TXT_masks
│   ├── 000_img_group1_cp_outlines.txt
│   ├── 001_img_group1_cp_outlines.txt
│   ├── 002_img_group1_cp_outlines.txt
│   ├── 003_img_group2_cp_outlines.txt
│   ├── 004_img_group2_cp_outlines.txt
│   └── 005_img_group2_cp_outlines.txt
└── Visualization
    └── Plot.pdf
```
* Cellpose_npy
    * These are the .npy files readable by the CellPose GUI
* Measurements
    * These are .csv files for the measurements taken of each ROI for each image, a .csv of all the data combined (called "CombinedData.csv").
* Original_Images
    * The original image files. 
* Overlays
    * .png files showing the CellPose-determined ROIs on top of the original image. 
* PNG_masks
    * .png files showing the CellPose-determined masks.
* TIF_masks
    * .tif files showing the CellPose-determined masks.
* TXT_masks
    * .txt files with coordinates of each ROI as deterined by CellPose.
* Visualization
    * .pdf visualization of user supplied groups and fluorescence intensity. 

## Arguments
### --help
Show help information in the command line (Default = `FALSE`)
### --check-dependencies
Check whether or not FIJI scripts, Homebrew, and Zenity are installed and available. This should be run the first time you run PASTA (Default = `FALSE`)  
### --cellpose-only 
Only run the CellPose segmentation portion of the pipeline (Default = `FALSE`)
### --visualization-only
Only run the visualizationn portion of the pipeline. This requires that you have already run the CellPose segmentation and FIJI analysis (Default = `FALSE`)
### --fiji-only
Only run the visualizationn portion of the pipeline. This requires that you have already run the CellPose segmentation (Default = `FALSE`)
### --full-pipeline
Run the full PASTA pipeline (Default = `FALSE`)
### --group=GROUP
Specifies a group (such as a treatment, timepoint, etc.) that can be used in visualization and analysis IMPORTANT: If you want to specify more than one group, you must use multiple --group=GROUP flags. The group names must also be in the original file name for the automatic grouping to be succesful. See the Step-bystep demo for an example of two groups (Default: No groups) 
### --dry-run
Test pipeline settings without running any analysis. Messages relaying what will be performed will still be displayed with some additional settings displayed, but no actual analysis will be run (Default = `FALSE`)
### --cellpose-model=MODEL
CellPose model to use for segmentation (REQUIRED). For more information on CellPose models or training a custom model, please visit the [CellPose website](https://cellpose.readthedocs.io/en/latest/models.html) 
### --cellpose-diameter=DIAMETER
cell diameter, if 0 will use the diameter of the training labels used in the model, or with built-in model will estimate diameter for each image (Default = 30.0)
### --cellpose-chan1=CHANNEL
channel to segment; 0: GRAY, 1: RED, 2: GREEN, 3: BLUE. Default: 0
### --cellpose-chan2=CHANNEL2
nuclear channel (if cyto, optional); 0: NONE, 1: RED, 2: GREEN, 3: BLUE. Default: 0
### --cellpose-gpu 
use gpu if torch with cuda installed (Default = `FALSE`)
### --cellpose-subdirectories
run processing on all subdirectories of current folder (DEFAULT = `FALSE`)
### --cellpose-resample
disable dynamics on full image (makes algorithm faster for images with large diameters) (DEFAULT = `FALSE`)
### --cellpose-no-normalization
do not normalize images (normalize=False) (DEFAULT = `FALSE`)
### --cellpose-minsize=MINSIZE
minimum number of pixels per mask, can turn off with -1 (Default: 15)
### --cellpose-flow-threshold=THRESHOLD
low error threshold, 0 turns off this optional QC step (Default: 0.4)
### --cellpose-cell-threshold=THRESHOLD
cellprob threshold, decrease to find more and larger masks (Default: 0)
### --cellpose-exclude-edges
discard masks which touch edges of image (DEFAULT = `FALSE`)
### --visualization-stats
whether or not to perform an ANOVA and post-hoc significance testing on user-defined groups

//@ String(label = "Some string", style = "text field") dir

// What directory do we want to process? 
// dir = getDirectory("Choose the folder with all your .tif files in it.");
dir_tifs = dir+"Original_Images"

// Get a list of all the files in the directory
fileList_tifs = getFileList(dir+File.separator+"Original_Images");

// Get a list of all the masks in the directory
fileList_masks = getFileList(dir+File.separator+"TXT_masks");

// make directory for the outputted measurements 
results_dir = dir + "/Measurements";
overlay_dir = dir + "/Overlays";
File.makeDirectory(results_dir);
File.makeDirectory(overlay_dir);

//activate batch mode
//setBatchMode(true);

// loop through all of the files in the directory
for (i = 0; i < lengthOf(fileList_tifs); i++) {

    // path to the file we're on 
	current_imagePath = dir+"/Original_Images"+File.separator+fileList_tifs[i];
	
	// open the image
	open(current_imagePath);
	
	// make sure we're editing the right image if there are other images open 
	selectImage (fileList_tifs[i]);

    // get the path to the txt mask file 
    current_txtPath = dir+"/TXT_masks"+File.separator+fileList_masks[i];

    // import the roi from cellpose
    run("CellPose converter", "filepath=["+current_txtPath+"]");

    // perform the actual measurements 
    roiManager("Measure");

    // flatten to export the masks over the original
    roiManager("Set Color", "white");
    roiManager("Set Line Width", 0);
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT");
    run("Flatten");
    save_file = overlay_dir + File.separator + fileList_tifs[i] + "_ROIs_Overlay.png";
    saveAs("png", save_file);

    // Save results table and close
    save_file = results_dir + File.separator + fileList_tifs[i] + "_Results.csv";
    saveAs("Results", save_file);

    run("Close All");
    close("ROI Manager");
    close("Results");
}

run("Quit");
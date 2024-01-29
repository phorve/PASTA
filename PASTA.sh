#!/bin/bash

##########################################################################
# Copyright 2024, Patrick Horve (pfh@uoregon.edu)                        #
#                                                                        #
# THE PASTA pipeline is free: you can redistribute it and/or modify       #
# it under the terms of the MIT license.                                 #
#                                                                        #
#                                                                        #
# This pipeline is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# MIT license for more details.                                          #
#                                                                        #
##########################################################################

# Main Functions #############################################################################################
die() { 
     echo "$*" >&2
     echo
     exit 2 
}
##############################################################################################################
needs_arg() { 
     if [ -z "$OPTARG" ]; then 
          die "ERROR: An argument is required for --$OPT!"; 
     fi; 
}
##############################################################################################################
usage() {
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "| bash PASTA.sh                                                                                   |"
     echo "|     [--cellpose-only]                      [--group=GROUP]                                      |"
     echo "|     [--fiji-only]                          [--full-pipeline]                                    |"
     echo "|     [--dry-run]                            [--cellpose-model=MODEL]                             |" 
     echo "|     [--cellpose-diameter=DIAMETER]         [--cellpose-chan1=CHANNEL]                           |" 
     echo "|     [--cellpose-chan2=CHANNEL2]            [--cellpose-gpu]                                     |" 
     echo "|     [--cellpose-subdirectories]            [--cellpose-resample]                                |" 
     echo "|     [--cellpose-no-normalization]          [--cellpose-minsize=MINSIZE]                         |"
     echo "|     [--cellpose-flow-threshold=THRESHOLD]  [--cellpose-cell-threshold=THRESHOLD]                |" 
     echo "|     [--cellpose-exclude-edges]             [--visualization-stats]                              |"  
     echo "|     [--check-dependencies]                 [--visualization-only]                               |"
     echo "|     [--usage]                              [--help]                                             |"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo
}
##############################################################################################################
help_function() {
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|                                                                                                 |"
     echo "| This script will segment individual cells in a 2D image using Cellpose, utilize this            |" 
     echo "| segmentation to create masks, measure the mean fluorescence in each mask in the original        |"
     echo "| .tif or .png files, and optionally output a plot of mean fluorescence intensity of those        |" 
     echo "| masks based on user-specified groups.                                                           |"
     echo "|                                                                                                 |"
     echo "| Additionally, individual sections of this script can be run individually, assuming that all     |"
     echo "| required files are present for that section to run. Individual sections can be run using        |" 
     echo "| using the --cellpose-only, --fiji-only, and --visualization-only flags.                         |"
     echo "|                                                                                                 |"
     echo "| More information about Cellpose can be found at https://www.cellpose.org                        |"
     echo "|                                                                                                 |"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|                                                                                                 |"
     echo "|         Run the full pipeline with default settings:                                            |" 
     echo "|                                                                                                 |"
     echo "|              bash PASTA.sh --full-pipeline --cellpose-model=cyto                                |"
     echo "|              ----> This will run the full pipeline. This includes:                              |" 
     echo "|                   - Cellpose segmentation                                                       |" 
     echo "|                   - ImageJ ROI analysis of Cellpose masks                                       |" 
     echo "|                   - Final data output                                                           |"
     echo "|                        - .csv data file                                                         |"
     echo "|                   - Visualization                                                               |"
     echo "|                                                                                                 |"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|                                                                                                 |"
     echo "|         Run only the Cellpose segmentation:                                                     |" 
     echo "|                                                                                                 |"
     echo "|              bash PASTA.sh --cellpose-only --cellpose-model=cyto                                |"
     echo "|              ----> This will only run the Cellpose segmentation                                 |"
     echo "|              Note: Training of new custom CellPose models should                                |"
     echo "|                    be performed using standalone Cellpose.                                      |"
     echo "|                                                                                                 |"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|                                                                                                 |"
     echo "|         Run only the Cellpose segmentation:                                                     |" 
     echo "|                                                                                                 |"
     echo "|              bash PASTA.sh --fiji-only                                                          |"
     echo "|              ----> This will only run the ImageJ ROI analysis of Cellpose masks, merge          |"
     echo "|              the outputted data from ImageJ, and create a final data output (.csv + .pzfx file) |"
     echo "|                                                                                                 |"
     echo "|-------------------------------------------------------------------------------------------------|"        
     echo "|                                                                                                 |"
     echo "|         Run only the visualization segmentation:                                                |" 
     echo "|                                                                                                 |"
     echo "|              bash PASTA.sh --visualization-only                                                 |"
     echo "|              ----> This will only create the final visualization.                               |"
     echo "|                                                                                                 |"
     echo "|-------------------------------------------------------------------------------------------------|"  
     echo "|-------------------------------------------------------------------------------------------------|"  
     usage
     echo
     echo 
}
##############################################################################################################
check_deps(){
     if [ "$CHECK_DEPS" = "TRUE" ]; then
          echo
          echo
          echo "|------ Checking for all dependencies"
          if [ -f /Applications/Fiji.app/plugins/CellPose_converter.py ]; then
               echo "    |"
               echo "    |---- CellPose_converter.py found"
          else
               echo "    |"
               echo "    |---- CellPose_converter.py not found"
               cp ./CellPose_converter.py /Applications/Fiji.app/plugins 
               echo "         |---- added to FIJI"
          fi
          BREW_CHECK=$(which brew)
          if [ -z "$BREW_CHECK" ]; then 
               echo "    |"
               echo "    |---- Homebrew not found"
               /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
               echo "         |---- Homebrew installed"
          else
               echo "    |"
               echo "    |---- Homebrew found"
          fi
          Z_CHECK=$(zenity --version)
          if [ -z "$Z_CHECK" ]; then 
               echo "    |"
               echo "    |---- Zenity not found"
               brew install zenity
               echo "         |---- Zenity installed"
          else
               echo "    |"
               echo "    |---- Zenity found"
          fi
          echo 
          echo
     fi
}
##############################################################################################################
cellpose() {
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     if [ $DRY = "no" ]; then
          echo "|--------------------------------Beginning the Cellpose segmentation------------------------------|"
     else
          echo "|-------------------------DRY RUN: Beginning the Cellpose segmentation----------------------------|"
          echo "|----------------------------Note: No actual analysis will be run---------------------------------|"
     fi
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo

     ## actvate the environment
     source activate base
     conda activate cellpose

     # Check to make sure that a model has been specified 
     if [ $CELLPOSE_MODEL = "none" ]; then
          die "ERROR: An argument is required when running Cellpose! Use --cellpose-model=MODEL to specify which model to use."
     fi

     echo python -m cellpose >> $input"/tmp.txt"
     echo "--dir $original_tif_path" >> $input"/tmp.txt"
     echo "--pretrained_model $CELLPOSE_MODEL" >> $input"/tmp.txt"
     echo "--diameter $CELLPOSE_DIAMETER" >> $input"/tmp.txt"
     echo "--chan $CELLPOSE_CHAN1" >> $input"/tmp.txt"
     if [ $CELLPOSE_CHAN2 = "none" ]; then 
          :
     fi
     if [ $CELLPOSE_CHAN2_DIRECTOR = "TRUE" ]; then
          echo "--chan2 $CELLPOSE_CHAN2" >> $input"/tmp.txt"
     fi
     echo "--verbose" >> $input"/tmp.txt"
     if [ $CELLPOSE_GPU = "TRUE" ]; then 
          echo "--gpu_device" >> $input"/tmp.txt"
     fi
     if [ $CELLPOSE_LEVEL_DOWN = "TRUE" ]; then 
               echo "--look_one_level_down" >> $input"/tmp.txt"
          fi
     if [ $CELLPOSE_RESAMPLE = "TRUE" ]; then 
          echo "--no_resample" >> $input"/tmp.txt"
     fi
     if [ $CELLPOSE_NORMALIZATION = "TRUE" ]; then 
          echo "--no_norm" >> $input"/tmp.txt"
     fi
     echo "--flow_threshold $CELLPOSE_FLOW_THRESHOLD" >> $input"/tmp.txt"
     echo "--cellprob_threshold $CELLPOSE_CELL_THRESHOLD" >> $input"/tmp.txt"
     if [ $CELLPOSE_EXCLUDE_EDGES = "TRUE" ]; then 
          echo "--exclude_on_edges" >> $input"/tmp.txt"
     fi
     echo "--save_png" >> $input"/tmp.txt"
     echo "--save_tif" >> $input"/tmp.txt"
     echo "--save_txt" >> $input"/tmp.txt"

     # fix the formatting of the txt file 
     echo $(cat $input"/tmp.txt") > $input"/tmp.txt"

     if [ $DRY = "no" ]; then
          # now run the actual cellpose command 
          source $input"/tmp.txt"

          # organize things now that cellpose has run 
          mkdir $input"/TIF_masks"
          mkdir $input"/TXT_masks"
          mkdir $input"/PNG_masks"
          mkdir $input"/Cellpose_npy"
          mv $original_tif_path"/"*masks.tif $input"/TIF_masks"
          mv $original_tif_path"/"*.txt $input"/TXT_masks"
          mv $original_tif_path"/"*masks.png $input"/PNG_masks"
          mv $original_tif_path"/"*.npy $input"/Cellpose_npy"
          rm $original_tif_path"/"*output.png

          # remove all the blank spaces in the outputted text files 
          for FILE in $input"/TXT_masks/"*; do 
               sed -i '' '/^$/d' $FILE
          done

          rm $input"/tmp.txt"
     else
          echo
          echo
          echo "|-------------------------------------------------------------------------------------------------|"
          echo "|-------------------------------------------------------------------------------------------------|"
          echo "|------------------DRY RUN: Images will be segemented using the following command:----------------|"
          echo
          cat $input"/tmp.txt"
          echo
          echo "|----------------------------Note: No actual analysis will be run---------------------------------|"
          echo "|-------------------------------------------------------------------------------------------------|"
          echo "|-------------------------------------------------------------------------------------------------|"
          echo
          echo
          rm $input"/tmp.txt"  
     fi
}
##############################################################################################################
fiji_main_function() {
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     if [ $DRY = "no" ]; then
          echo "|----------------------------------Beginning the ImageJ Analysis----------------------------------|"
     else
          echo "|------------------------------DRY RUN: Beginning the ImageJ Analysis-----------------------------|"
          echo "|-------------------------------Note: No actual analysis will be run------------------------------|"
     fi
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo
     
     # make the temporary script to run the iamgej macro
     echo "/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx --run ./CellPose_processing_macro.ijm 'dir=\"$input\"'" > $input"/tmp.sh" 

     if [ $DRY = "no" ]; then
          # Run the imagej macro 
          source $input"/tmp.sh"
     fi

     # Remove that temporary script 
     rm $input"/tmp.sh"
     
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     if [ $DRY = "no" ]; then
          echo "|----------------------------------Beginning the Data Merging-------------------------------------|"
          echo "|-------------------------The user specified groups are: '${multi[@]}'"
     else
          echo "|-------------------------------DRY RUN: Beginning the Data Merging-------------------------------|"
          echo "|-------------------------------Note: No actual analysis will be run------------------------------|"
          echo "|-------------------------The user specified groups are: '${multi[@]}'"
     fi
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo

     LENGTH=$(echo "${#multi[@]}")
     
     if [ $DRY = "no" ]; then
          Rscript ./DataMerging.R $LENGTH $input ${multi[@]}  --vanilla
     fi
}
##############################################################################################################
visualization() {
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     if [ $DRY = "no" ]; then
          echo "|------------------------------------Creating the Visualization-----------------------------------|"
     else
          echo "|--------------------------------DRY RUN: Creating the Visualization------------------------------|"
          echo "|-------------------------------Note: No actual visualization will be made------------------------|"
     fi
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo
     
     if [ $DRY = "no" ]; then
          mkdir $input/Visualization
          
          Rscript ./Visualization.R $input $PERFORM_STATS --vanilla

          if [ -f ./Rplots.pdf ]; then
               rm ./Rplots.pdf
          fi
     fi
}
# set defaults ###############################################################################################
CELLPOSE="no"
FIJI="no"
VISUALIZE="no"
DRY="no"
FULL="no"
CELLPOSE_MODEL="none"
CELLPOSE_DIAMETER=0
CELLPOSE_CHAN1=0
CELLPOSE_CHAN2="none"
CELLPOSE_CHAN2_DIRECTOR="FALSE"
CELLPOSE_GPU="FALSE"
CELLPOSE_LEVEL_DOWN="FALSE"
CELLPOSE_RESAMPLE="FALSE"
CELLPOSE_NORMALIZATION="FALSE"
CELLPOSE_FLOW_THRESHOLD=0.4
CELLPOSE_CELL_THRESHOLD=0
CELLPOSE_EXCLUDE_EDGES="FALSE"
PERFORM_STATS="FALSE"
CHECK_DEPS="FALSE"
# Parse options ##############################################################################################
while getopts hcfr-: OPT; do
     # support long options: https://stackoverflow.com/a/28466267/519360
     if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
          OPT="${OPTARG%%=*}"       # extract long option name
          OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
          OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
     fi
     case $OPT in
          group) 
               multi+=("$OPTARG")
          ;;
          cellpose-only )
               CELLPOSE="yes"     
          ;;
          fiji-only )
               FIJI="yes"
          ;;
          visualization-only )
               VISUALIZE="yes"
          ;;
          dry-run )
               DRY="yes"
          ;;
          full-pipeline )
               FULL="yes"
          ;;
          cellpose-model )
               if [ -z "$OPTARG" ]; then 
                    die "ERROR: A model is required when using the segmentation in Cellpose! Please see PASTA.sh --help or https://www.cellpose.org for more information"; 
               fi
               CELLPOSE_MODEL="$OPTARG"
          ;;
          cellpose-diameter )
               CELLPOSE_DIAMETER="${OPTARG:-$CELLPOSE_DIAMETER}"
          ;;
          cellpose-chan1 )
               CELLPOSE_CHAN1="${OPTARG:-$CELLPOSE_CHAN1}"
          ;;
          cellpose-chan2 )
               if [ -z "$OPTARG" ]; then 
                    die "ERROR: A channel input is required when specifying a second channel the segmentation in Cellpose! Please see PASTA.sh --help or https://www.cellpose.org for more information"; 
               else
                    CELLPOSE_CHAN2_DIRECTOR="TRUE"
                    CELLPOSE_CHAN2="${OPTARG:-$CELLPOSE_CHAN2}"
               fi    
          ;;
          cellpose-gpu )
               CELLPOSE_GPU="TRUE"
          ;;
          cellpose-subdirectories )
               CELLPOSE_LEVEL_DOWN="TRUE"
          ;;
          cellpose-resample )
               CELLPOSE_RESAMPLE="TRUE"
          ;;
          cellpose-no-normalization )
               CELLPOSE_NORMALIZATION="TRUE"
          ;;
          cellpose-flow-threshold )
               needs_arg
               CELLPOSE_FLOW_THRESHOLD="${OPTARG:-$CELLPOSE_FLOW_THRESHOLD}"
          ;;
          cellpose-cell-threshold )
               needs_arg
               CELLPOSE_CELL_THRESHOLD="${OPTARG:-$CELLPOSE_CELL_THRESHOLD}"
          ;;
          cellpose-exclude-edges )
               CELLPOSE_EXCLUDE_EDGES="TRUE"
          ;;
          visualization-stats )
               PERFORM_STATS="TRUE"
          ;;
          check-dependencies )
               CHECK_DEPS="TRUE"
          ;;
          help ) # Handle the -h flag - Display script help information
               help_function     
          ;;
          usage )
               usage
          ;;
          test )
               TEST="TRUE" # for testing new portions of the script. Doesn't actually link to anything right now 
          ;;
          * )
               die "ERROR: Illegal option --$OPT" 
          ;;
     esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list
check_deps
# Full pipeline ############################################################################################## 
if [ $FULL = "yes" ]; then
     input=$(zenity  --file-selection --title="Choose a directory" --file-filter=""Downloads" "Desktop"" --directory)
     original_tif_path=($input"/Original_Images")
     cellpose
     fiji_main_function
     visualization
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|---------------------------------------------Completed-------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo
fi
# Cellpose only ##############################################################################################
if [ $CELLPOSE = "yes" ]; then
     input=$(zenity  --file-selection --title="Choose a directory" --file-filter=""Downloads" "Desktop"" --directory)
     original_tif_path=($input"/Original_Images")
     cellpose
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|---------------------------------Cellpose Segmentation Completed---------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo
fi
# FIJI only ##################################################################################################
if [ $FIJI = "yes" ]; then
     input=$(zenity  --file-selection --title="Choose a directory" --file-filter=""Downloads" "Desktop"" --directory)
     original_tif_path=($input"/Original_Images")
     fiji_main_function
     echo
     echo
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|---------------------------------------------Completed-------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo "|-------------------------------------------------------------------------------------------------|"
     echo
     echo
fi   
# Visualization only #########################################################################################
if [ $VISUALIZE = "yes" ]; then
     input=$(zenity  --file-selection --title="Choose a directory" --file-filter=""Downloads" "Desktop"" --directory)
     original_tif_path=($input"/Original_Images")
     visualization
fi

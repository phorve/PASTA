# Make sure that needed packages are installed
install.packages(setdiff(c("plyr", "tidyverse", "ggprism", "pzfx", "multcompView", "rstatix", "stringr"), rownames(installed.packages())), repos = "http://cran.us.r-project.org")
# load the packages 
suppressPackageStartupMessages(library(plyr, quietly = T))
suppressPackageStartupMessages(library(tidyverse, quietly = T))
suppressPackageStartupMessages(library(ggprism, quietly = T))
suppressPackageStartupMessages(library(pzfx, quietly = T))
suppressPackageStartupMessages(library(multcompView, quietly = T))
suppressPackageStartupMessages(library(rstatix, quietly = T))
suppressPackageStartupMessages(library(stringr, quietly = T))
# Get the inputs from the bash script
args <- commandArgs()

# What isthe main folder that we want to look at 
directory = args[7]

# How many visualization groups were provided by the user? 
group_number = as.numeric(args[6])

# Are there user-defined groups and if so, what are they? 
if (group_number > 0)
{
  group_length_pull = group_number-1
  groups = args[8:(8+group_length_pull)]
}
files_to_read <- list.files(path = paste0(directory,"/Measurements"),full.names = T)
final_data = data.frame()
prism_data = data.frame()
counter = setNames(data.frame(matrix(ncol = 1, nrow = 0)), c("group"))
for (f in 1:length(files_to_read)){
  temp_data = read.csv(files_to_read[f])
  temp_data$original_data_file = files_to_read[f]
  for (group in groups)
  {
    if (grepl(group, files_to_read[f]) == TRUE) 
    {
      # Add the treatment data to this dataframe
      temp_data$Treatment = group
      # keep track of how many times this group has happened 
      temp_counter = data.frame("group" = group)
      counter = rbind(counter, temp_counter)
    }
  }
  final_data = rbind(final_data, temp_data) # this is the final dataframe to be outputted as a .csv file 
  
  # now we have to build the prism data 
  #new.col = temp_data$Mean
  #this_treatment = unique(temp_data$Treatment)
  #temp_prism_data = data.frame("treatment" = new.col)
  #this_count = length(which(counter$group == this_treatment))
  #if (f == 1)
  #{
  #  prism_data = temp_prism_data
  #  this_treatment = paste0(this_treatment,"_",this_count)
  #  prism_data = prism_data %>% rename(!!this_treatment := treatment) 
  #}
  #else
  #{
  #  if (nrow(prism_data) > length(new.col))
  #  {
  #    prism_data$new.col <- c(new.col, rep(NA, nrow(prism_data)-length(new.col))) 
  #  }
  #  else
  #  {
  #    difference = abs(length(new.col)-nrow(prism_data))
  #    prism_data[nrow(prism_data)+difference,] <- NA
  #    prism_data$new.col = new.col
  #  }
  #  if (this_count > 0)
  #  {
  #    this_treatment = paste0(this_treatment,"_",this_count)
  #    prism_data = prism_data %>% rename(!!this_treatment := new.col)
  #  }
  # else
  # {
  #    prism_data = prism_data %>% rename(!!this_treatment := new.col)
  #  }
  #}
}

# Write the dataframe csv file
write_csv(final_data, file = paste0(directory,"/Measurements/CombinedData.csv"))

# Write the prism file
#write_pzfx(prism_data, row_names=FALSE, path = paste0(directory,"/Measurements/CombinedData.pzfx"))

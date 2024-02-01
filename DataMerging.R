# Make sure that needed packages are installed
install.packages(
  setdiff(
    c(
      "plyr",
      "tidyverse",
      "ggprism",
      "pzfx",
      "multcompView",
      "rstatix",
      "stringr"
    ),
    rownames(installed.packages())
  ),
  repos = "http://cran.us.r-project.org"
)
# load the packages
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ggprism))
suppressPackageStartupMessages(library(pzfx))
suppressPackageStartupMessages(library(multcompView))
suppressPackageStartupMessages(library(rstatix))
suppressPackageStartupMessages(library(stringr))
# Get the inputs from the bash script
args <- commandArgs()
# What isthe main folder that we want to look at
directory <- args[7]
# How many visualization groups were provided by the user?
group_number <- as.numeric(args[6])
# Are there user-defined groups and if so, what are they?
if (group_number > 0) {
  group_length_pull <- group_number - 1
  groups <- args[8:(8 + group_length_pull)]
}
files_to_read <- list.files(
  path = paste0(directory, "/Measurements"),
  full.names = T
)
final_data <- data.frame()
prism_data <- data.frame()
counter <- setNames(data.frame(matrix(ncol = 1, nrow = 0)), c("group"))
for (f in 1:length(files_to_read)) {
  temp_data <- read.csv(files_to_read[f])
  temp_data$original_data_file <- files_to_read[f]
  for (group in groups) {
    if (grepl(group, files_to_read[f]) == TRUE) {
      # Add the treatment data to this dataframe
      temp_data$Treatment <- group
      # keep track of how many times this group has happened
      temp_counter <- data.frame("group" = group)
      counter <- rbind(counter, temp_counter)
    }
  }
  # this is the final dataframe to be outputted as a .csv file
  final_data <- rbind(final_data, temp_data)
}
# Write the dataframe csv file
write_csv(final_data, file = paste0(directory, "/Measurements/CombinedData.csv"))

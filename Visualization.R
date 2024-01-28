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
directory = args[6]
perform_stats = args[7]

# Read in the data frame
data = read.csv(paste0(directory,"/Measurements/CombinedData.csv"))

if (perform_stats == TRUE)
{
  # Perform Anova
  aov <- aov(Mean ~ Treatment, data = data)

  # Post-hoc Tukey Multiple Comparisons
  tukey = TukeyHSD(aov)

  cld <- multcompLetters4(aov, tukey)

  cld <- as.data.frame.list(cld$Treatment)
  cld$Treatment = rownames(cld)
}

# Visualization
ggplot(data, aes(Treatment, Mean, fill = Treatment)) +
  geom_jitter(shape = 21, size = 3) +
  geom_violin(alpha = 0.5, outlier.shape = NA) +
  geom_boxplot(width=0.1, outlier.shape = NA, fill = "white") +
  theme_prism() +
  theme(legend.position = "none") +
  ylab("Mean fluorescence intensity") +
  theme(axis.text.x = element_text(size = 10, face = "bold"),
        axis.text.y = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.title.x = element_text(size = 10, face = "bold"))
  {if (perform_stats == TRUE)list(geom_text(data = cld, aes(x = Treatment, y = (max(data$Mean, na.rm = T)+5), label = Letters, size = 10), color = "black", group = "Treatment"))}
ggsave(filename = paste0(directory,"/Visualization/Plot.pdf"), height = 11, width = 8.5, units = "in")
pdf(NULL)
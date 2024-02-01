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
# What is the main folder that we want to look at
directory <- args[7]
perform_stats <- args[8]
# Read in the data frame
data <- read.csv(paste0(directory, "/Measurements/CombinedData.csv"))
# How many visualization groups were provided by the user?
plot_number <- as.numeric(args[6])
# Are there user-defined groups and if so, what are they?
plot_number_pull <- plot_number - 1
plots <- args[9:(9 + plot_number_pull)]
for (plot in plots) {
  if (plot == "Count") {
    count_data <- data %>%
      group_by(original_data_file, Treatment) %>%
      count(original_data_file)
    if (perform_stats == TRUE) {
      # Perform Anova
      aov <- aov(n ~ Treatment, data = count_data)
      # Post-hoc Tukey Multiple Comparisons
      tukey <- TukeyHSD(aov)
      cld <- multcompLetters4(aov, tukey)
      cld <- as.data.frame.list(cld$Treatment)
      cld$Treatment <- rownames(cld)
    }
    # Visualization
    ggplot(count_data, aes(x = Treatment, y = n, fill = Treatment)) +
      geom_jitter(shape = 21, size = 3) +
      geom_boxplot(outlier.shape = NA, alpha = 0.5) +
      theme_prism() +
      theme(legend.position = "none") +
      ylab("# of cells") +
      theme(
        axis.text.x = element_text(size = 10, face = "bold"),
        axis.text.y = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.title.x = element_text(size = 10, face = "bold")
      ) +
      {
        if (perform_stats == TRUE) {
          list(geom_text(
            data = cld, aes(
              x = Treatment,
              y = max(count_data$n) + 10,
              label = Letters,
              size = 10
            ),
            color = "black",
            group = "Treatment"
          ))
        }
      }
    ggsave(
      filename = paste0(directory, "/Visualization/", plot, "_Plot.pdf"),
      height = 11,
      width = 8.5,
      units = "in"
    )
  } else {
    if (perform_stats == TRUE) {
      # Perform Anova
      aov <- aov(as.formula(paste(plot, " ~ Treatment")), data = data)
      # Post-hoc Tukey Multiple Comparisons
      tukey <- TukeyHSD(aov)
      cld <- multcompLetters4(aov, tukey)
      cld <- as.data.frame.list(cld$Treatment)
      cld$Treatment <- rownames(cld)
    }
    # Visualization
    ggplot(data, aes(x = Treatment, y = .data[[plot]], fill = Treatment)) +
      geom_jitter(shape = 21, size = 3) +
      geom_violin(alpha = 0.5, outlier.shape = NA) +
      geom_boxplot(width = 0.1, outlier.shape = NA, fill = "white") +
      theme_prism() +
      theme(legend.position = "none") +
      ylab(paste0(plot)) +
      theme(
        axis.text.x = element_text(size = 10, face = "bold"),
        axis.text.y = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, face = "bold"),
        axis.title.x = element_text(size = 10, face = "bold")
      ) +
      {
        if (perform_stats == TRUE) {
          list(geom_text(
            data = cld, aes(
              x = Treatment,
              y = (max(data[[plot]])) + 10,
              label = Letters,
              size = 10
            ),
            color = "black",
            group = "Treatment"
          ))
        }
      }
    ggsave(
      filename = paste0(directory, "/Visualization/", plot, "_Plot.pdf"),
      height = 11,
      width = 8.5,
      units = "in"
    )
  }
}

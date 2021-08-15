
library(dplyr)
library(ggpubr)
library(cowplot)

folder <- 'C:\\<your-folder>\\Chapter14'

histodensity_lst <- readRDS(file.path(folder, 'Demo\\histodensity_lst.rds'))
histodensity_transf_lst <- readRDS(file.path(folder, 'Demo\\histodensity_transf_lst.rds'))

# Uncomment if the script is not run in Power BI
#dataset <- data.frame(numeric_col_name = names(histodensity_lst))

col_name <- (dataset %>% pull(1))[1]
dataset_type <- (dataset %>% pull(2))[1]

if (dataset_type == 'standard') {
  histodensity_lst[[col_name]]
} else {
  histodensity_transf_lst[[col_name]]
}



library(ggplot2)
library(naniar)

# Load the dataset with proper column data types
init_path <- r'{C:\<your-path>\Chapter14\R\00-init-dataset.R}'
if(!exists('foo', mode='function')) source(init_path)


gg_miss_upset(tbl, text.scale = 2)

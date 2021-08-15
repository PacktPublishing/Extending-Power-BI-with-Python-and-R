
library(ggplot2)
library(naniar)

# Load the dataset with proper column data types
init_path <- r'{C:\<your-folder>\Chapter14\R\00-init-dataset.R}'
if(!exists('foo', mode='function')) source(init_path)
 
# # Uncomment this code if not in Power BI
# dataset <- tbl

gg_miss_var(tbl, show_pct = T) + 
  theme(
    axis.text = element_text(size=14)
  )

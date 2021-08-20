
library(ggplot2)
library(naniar)

# Load the dataset with proper column data types
init_path <- r'{C:\Users\LucaZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter14\R\00-init-dataset.R}'
if(!exists('foo', mode='function')) source(init_path)


gg_miss_upset(tbl, text.scale = 2)

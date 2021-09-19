
library(dplyr)
library(ggplot2)


# # To run this code not in Power BI you have:
# # 1. Run all the code you can find in the file '09-create-association-objects.R'
# # 2. Uncomment the following code
# numeric_method <- 'pearson'
# categorical_method <- 'theil'
# 
# dataset <- corr_tbl %>% 
#   filter( numeric_corr_type == numeric_method & categorical_corr_type == categorical_method)
# #-----

dataset %>% 
  ggplot( aes(x=row, y=col, fill=corr) ) +
  geom_tile() +
  geom_text(aes(row, col, label = round(corr, 2)), color = "white", size = 4) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
    axis.text = element_text(size=14)
  )


library(dplyr)
library(corrr)


# You need to select only numerical columns
# in order to make correlate() work
corr_tbl <- dataset %>% 
    select( where(is.numeric) ) %>% 
    correlate( method = 'spearman' )

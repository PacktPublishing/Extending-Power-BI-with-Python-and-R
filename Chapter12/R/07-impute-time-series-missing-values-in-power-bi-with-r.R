
library(imputeTS)
library(dplyr)
library(lubridate)


air_df <- dataset %>% 
    mutate( date = ymd(date) )

#-- Imputations
air_df$locf <- na_locf(air_df$value)
air_df$nocb <- na_locf(air_df$value, option = 'nocb')

air_df$ewma_1 <- na_ma(air_df$value, k = 1, maxgap = 3)
air_df$ewma_2 <- na_ma(air_df$value, k = 2, maxgap = 3)
air_df$ewma_3 <- na_ma(air_df$value, k = 3, maxgap = 3)
air_df$ewma_6 <- na_ma(air_df$value, k = 6, maxgap = 3)
air_df$ewma_9 <- na_ma(air_df$value, k = 9, maxgap = 3)

air_df$linear <- na_interpolation(air_df$value, option = 'linear', maxgap = 3)
air_df$spline <- na_interpolation(air_df$value, option = 'spline', maxgap = 3)

air_df$seadec <- na_seadec(air_df$value, find_frequency = T, maxgap = 3)


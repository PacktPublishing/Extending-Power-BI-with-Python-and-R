
library(imputeTS)
library(dplyr)
library(purrr)
library(lubridate)


air_df <- read.csv('https://bit.ly/airpassengers')

# Create 10% of missing values in the vector
set.seed(57934)
value_missing <- missForest::prodNA(air_df['value'], noNA = 0.1)

# Force a larger gap in the vector
value_missing[67:68,] <- NA

# Add the vector with missing values to the dataframe
air_missing_df <- air_df %>% 
    mutate( date = ymd(date) ) %>% 
    rename( complete = value ) %>% 
    bind_cols( value = value_missing )
    
air_missing_df


#-- LOCF imputation ----
air_missing_df$locf <- na_locf(air_missing_df$value)

ggplot_na_imputations( air_missing_df$value, air_missing_df$locf)

#-- NOCB imputation ----
air_missing_df$nocb <- na_locf(air_missing_df$value, option = 'nocb')

ggplot_na_imputations( air_missing_df$value, air_missing_df$nocb)

#-- EWMA imputation ----
air_missing_df$ewma_1 <- na_ma(air_missing_df$value, k = 1, maxgap = 3)
air_missing_df$ewma_2 <- na_ma(air_missing_df$value, k = 2, maxgap = 3)
air_missing_df$ewma_3 <- na_ma(air_missing_df$value, k = 3, maxgap = 3)
air_missing_df$ewma_6 <- na_ma(air_missing_df$value, k = 6, maxgap = 3)
air_missing_df$ewma_9 <- na_ma(air_missing_df$value, k = 9, maxgap = 3)


ggplot_na_imputations( air_missing_df$value, air_missing_df$ewma_3)
ggplot_na_imputations( air_missing_df$value, air_missing_df$ewma_9)


#-- LINEAR imputation ----
air_missing_df$linear <- na_interpolation(air_missing_df$value, option = 'linear', maxgap = 3)

ggplot_na_imputations( air_missing_df$value, air_missing_df$linear)


#-- SPLINE imputation ----
air_missing_df$spline <- na_interpolation(air_missing_df$value, option = 'spline', maxgap = 3)

ggplot_na_imputations( air_missing_df$value, air_missing_df$spline)


#-- Seasonally Decomposed imputation ----
air_missing_df$seadec <- na_seadec(air_missing_df$value, find_frequency = T, maxgap = 3)

ggplot_na_imputations( air_missing_df$value, air_missing_df$seadec)


#-- Accuracy ----
acc_locf <- forecast::accuracy(air_missing_df$locf, x = air_missing_df$complete) %>% as_tibble()
acc_nocb <- forecast::accuracy(air_missing_df$nocb, x = air_missing_df$complete) %>% as_tibble()
acc_ewma_1 <- forecast::accuracy(air_missing_df$ewma_1, x = air_missing_df$complete) %>% as_tibble()
acc_ewma_2 <- forecast::accuracy(air_missing_df$ewma_2, x = air_missing_df$complete) %>% as_tibble()
acc_ewma_3 <- forecast::accuracy(air_missing_df$ewma_3, x = air_missing_df$complete) %>% as_tibble()
acc_ewma_6 <- forecast::accuracy(air_missing_df$ewma_6, x = air_missing_df$complete) %>% as_tibble()
acc_ewma_9 <- forecast::accuracy(air_missing_df$ewma_9, x = air_missing_df$complete) %>% as_tibble()
acc_linear <- forecast::accuracy(air_missing_df$linear, x = air_missing_df$complete) %>% as_tibble()
acc_spline <- forecast::accuracy(air_missing_df$spline, x = air_missing_df$complete) %>% as_tibble()
acc_seadec <- forecast::accuracy(air_missing_df$seadec, x = air_missing_df$complete) %>% as_tibble()

acc_tbl <- acc_locf %>% 
    bind_rows(acc_nocb) %>%
    bind_rows(acc_ewma_1) %>%
    bind_rows(acc_ewma_2) %>%
    bind_rows(acc_ewma_3) %>%
    bind_rows(acc_ewma_6) %>%
    bind_rows(acc_ewma_9) %>%
    bind_rows(acc_linear) %>%
    bind_rows(acc_spline) %>%
    bind_rows(acc_seadec) %>% 
    bind_cols( strategy = c('locf', 'nocb', 'ewma_1', 'ewma_2', 'ewma_3',
                            'ewma_6', 'ewma_9', 'linear', 'spline', 'seadec') ) %>% 
    relocate(strategy)

acc_tbl

# The minimum error is given by the seadec strategy

# Best imputed values vs ground truth
p_spline <- ggplot_na_imputations(x_with_na = air_missing_df$value,
                                  x_with_imputations = air_missing_df$spline,
                                  x_with_truth = air_missing_df$complete,
                                  title = 'Imputed Values with Spline',
                                  subtitle = '')

p_seadec <- ggplot_na_imputations(x_with_na = air_missing_df$value,
                                  x_with_imputations = air_missing_df$seadec,
                                  x_with_truth = air_missing_df$complete,
                                  title = 'Imputed Values with Seadec',
                                  subtitle = '')

figure <- ggpubr::ggarrange(p_spline, p_seadec,
                            #labels = c("Spline", "Seadec"),
                            ncol = 1, nrow = 2)

figure



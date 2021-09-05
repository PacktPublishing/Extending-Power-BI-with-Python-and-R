
library(dplyr)
library(lubridate)
library(ggplot2)
library(naniar)
library(imputeTS)



#-- Diagnosing tabular data ----
dataset_url <- 'http://bit.ly/titanic-dataset-csv'
tbl <- readr::read_csv(dataset_url)
tbl


# Plot of missing values in the entire dataset
vis_miss(tbl) +
    theme(
        plot.title = element_text(size=24),
        axis.title = element_text(size=18),
        axis.text = element_text(size=14),
        axis.text.x = element_text(angle = 70),
        legend.text = element_text(size=12)
    )

# Missing values summary
miss_var_summary(tbl)

# Plot of the number of missing
# values for each variable
gg_miss_var(tbl)


# Which combinations of variables occur to be missing together?
gg_miss_upset(tbl, text.scale = 2)



#-- Diagnosing time series data ----

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

# Visualize the distribution of missing values
ggplot_na_distribution(air_missing_df$value)

# Get statistics about missing values
statsNA(air_missing_df$value)




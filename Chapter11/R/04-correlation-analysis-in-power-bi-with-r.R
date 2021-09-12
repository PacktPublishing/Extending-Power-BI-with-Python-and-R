
library(dplyr)
library(purrr)


# Inspired by the following code:
# https://github.com/shakedzy/dython/blob/06aa19f3332de4f80478f5e8bf3ba868f7ddfb63/dython/nominal.py#L194
correlation_ratio <- function(categories, measurements, numeric_replace_value = 0) {
    
    measurements[is.na(measurements)] <- numeric_replace_value
	categories <- addNA(categories)
    
    fcat <- as.numeric(categories)
    cat_num <- max(fcat)
    y_avg_array <- rep(0, cat_num)
    n_array <- rep(0, cat_num)
    
    for (i in 1:(cat_num)) {
        cat_measures <- measurements[fcat==i]
        n_array[i] <- length(cat_measures)
        y_avg_array[i] = mean(cat_measures)
    }
    
    y_total_avg <- sum(y_avg_array * n_array) / sum(n_array)
    
    numerator <- sum((y_avg_array - y_total_avg)^2 * n_array)
    
    denominator <- sum((measurements - y_total_avg)^2)
    
    eta <- ifelse(numerator == 0, 0, sqrt(numerator / denominator))
    
    return(eta)
    
}


calc_corr <- function(data, row_name, col_name, numeric_replace_value = 0, theil_uncert=TRUE) {

    row_vec <- data[[row_name]]
    col_vec <- data[[col_name]]
    
    
    row_data_type <- class(row_vec)
    col_data_type <- class(col_vec)

    corr <- NA
    
    if (row_name == col_name) {
        
        corr <- 1.0
    
    } else if (row_data_type == 'numeric' & col_data_type == 'numeric') {
    
        col_vec[is.na(col_vec)] <- numeric_replace_value
        row_vec[is.na(row_vec)] <- numeric_replace_value
        
        c <- tibble(row_vec, col_vec)
        names(c) <- c(row_name, col_name)
        
        corr <- (c %>% corrr::correlate(method = 'pearson', quiet = T))[[1,3]]
        
    } else if (row_data_type == 'numeric' & (col_data_type == 'character' | col_data_type == 'factor')) {
        
        if (col_data_type == 'character') {
            col_vec <- addNA(as.factor(col_vec))
        }
        
        corr <- correlation_ratio(categories = col_vec, measurements = row_vec,
                                  numeric_replace_value = 0)
        
    } else if ((row_data_type == 'character' | row_data_type == 'factor') & col_data_type == 'numeric') {
        
        if (row_data_type == 'character') {
            row_vec <- addNA(as.factor(row_vec))
        }
        
        corr <- correlation_ratio(categories = row_vec, measurements = col_vec,
                                  numeric_replace_value = 0)
        
    } else if ((row_data_type == 'character' | row_data_type == 'factor') & (col_data_type == 'character' | col_data_type == 'factor')) {
        
        if (row_data_type == 'character') {
            row_vec <- addNA(as.factor(row_vec))
        }
        
        if (col_data_type == 'character') {
            col_vec <- addNA(as.factor(col_vec))
        }
        
        if (theil_uncert) {
            corr <- DescTools::UncertCoef(row_vec, col_vec, direction = 'row')
        } else {
            corr <- rstatix::cramer_v(x=row_vec, y=col_vec)
        }
        
    }
    
    return(corr)

}

# # In case of debug on RStudio
# dataset_url <- 'http://bit.ly/titanic-dataset-csv'
# dataset <- readr::read_csv(dataset_url)

# Make sure the expected data types are correct
cat_cols <- c('Survived', 'Pclass', 'Name', 'Sex', 'Ticket', 'Cabin', 'Embarked')
num_cols <- c('PassengerId', 'Age', 'SibSp', 'Parch', 'Fare')

df <- dataset %>% 
    mutate( across(all_of(cat_cols), as.factor) ) %>%
    mutate( across(all_of(num_cols), as.numeric) )

# Create two data frames having the only column containing
# the dataframe column names as values
row <- data.frame(row=names(df))
col <- data.frame(col=names(df))

# Create the cross join dataframe from the previous two ones
ass <- tidyr::crossing(row, col)

# Add the corr column containing correlation values
corr_tbl <- ass %>% 
    mutate( corr = map2_dbl(row, col, ~ calc_corr(data = df, row_name = .x, col_name = .y, theil_uncert = T)) )

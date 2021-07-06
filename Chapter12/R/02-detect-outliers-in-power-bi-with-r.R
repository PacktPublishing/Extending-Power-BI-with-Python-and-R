library(dplyr)
library(stringr)
library(recipes)
library(robust)


add_is_outlier_IQR <- function(data, col_name) {
    
    x <- data[[col_name]]
    quar <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
    iqr <- diff(quar)
    k <- 1.5
    
    outliers_col_name <- str_glue('is_{str_replace(col_name, " ", "_")}_outlier')
     
    data[[outliers_col_name]] <- ifelse((x < quar[1] - k * iqr) | (x > quar[2] + k * iqr), 1, 0)
    
    return(data)
}


yeo_johnson_transf <- function(data) {
    
    rec <- recipe(data, quality ~ .)
    
    rec <- rec %>%
        step_center( all_numeric(), - all_outcomes() ) %>%
        step_scale( all_numeric(), - all_outcomes() ) %>%
        step_YeoJohnson( all_numeric(), -all_outcomes() )
    
    prep_rec <- prep( rec, training = data )
    
    res_list <- list( df_yeojohnson = bake( prep_rec, data ),
                      lambdas = prep_rec$steps[[3]][["lambdas"]] )
}



# Get numeric column names but the quality
numeric_col_names <- dataset %>% 
    select( where(is.numeric), -quality ) %>% 
    names()

# As you see there are outliers, let's add a boolean 
# column to the dataframeindicating which row
# has a sulphate outlier
df <- add_is_outlier_IQR(dataset, col_name = 'sulphates')


# Let's apply Yeo-Johnson transformations
# in order to remove skewness
yeo_johnson_list <- df %>% 
    yeo_johnson_transf()

df_transf <- yeo_johnson_list$df_yeojohnson


# Let's compute the squared Mahalanobis distances using
# the Minimum Covariance Determinant to calculate a
# robust covariance matrix
data <- df_transf %>%
    select( all_of(numeric_col_names) )

cov_obj <- data %>% 
    covRob( estim="mcd", alpha=0.7 )

center <- cov_obj$center
cov <- cov_obj$cov

distances <- data %>%
    mahalanobis( center=center, cov=cov )


# Given a cutoff value associated with the statistical significance
# with which we want to determine outliers, we obtain the corresponding
# threshold value above which to consider an observation an outlier
cutoff <- 0.98
degrees_of_freedom <- ncol(data) # given by the number of variables (columns)

outliers_value_cutoff <- qchisq(cutoff, degrees_of_freedom) # threshold value


data <- data %>% 
    mutate(
        
        # Indicator column of sulphates outliers
        is_sulphates_outlier      = df$is_sulphates_outlier,
        
        # Indicator column of outliers detected with Mahalanobis distance
        is_mahalanobis_outlier    = distances > outliers_value_cutoff,
        
        # Probability that an observation is a Mahalanobis outlier not by chance
        mahalanobis_outlier_proba = pchisq(distances, ncol(data))
    )


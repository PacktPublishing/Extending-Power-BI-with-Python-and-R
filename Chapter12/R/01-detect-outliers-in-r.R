

library(dplyr)
library(stringr)
library(recipes)
library(robust)
library(ggplot2)


boxPlot <- function(data, varx, vary, vargrp, title, xlab, ylab) {
    data %>% 
        ggplot( aes_string(x=varx, y=vary, group=vargrp)) +
        geom_boxplot(fill='orange') +
        theme(
            legend.position="none",
            plot.title = element_text(size=24),
                axis.title = element_text(size=18),
                axis.text = element_text(size=14)
        ) +
        ggtitle(title) +
        xlab(xlab) +
        ylab(ylab)
}

dataframeHist <- function(data, bins = 10) {
    data %>% 
        tidyr::pivot_longer( cols = everything() ) %>% 
        ggplot( aes(value) ) +
        geom_histogram( fill='orange', na.rm = TRUE, bins = bins )+ 
        theme(
            legend.position="none",
            plot.title = element_text(size=24),
            axis.title = element_text(size=14),
            axis.text = element_text(size=10)
        ) +
        facet_wrap(~ name, scales = "free")
}


add_is_outlier_IQR <- function(data, col_name) {
    
    x <- data[[col_name]]
    quar <- quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
    iqr <- diff(quar)
    k <- 1.5
    
    outliers_col_name <- str_glue('is_{str_replace(col_name, " ", "_")}_outlier')
     
    data[[outliers_col_name]] <- ifelse((x < quar[1] - k * iqr) | (x > quar[2] + k * iqr), 1, 0)
    
    return(data)
}


yeo_johnson_transf <- function(data, target_name) {
  
  rec <- recipe(data, as.formula(paste0(target_name, ' ~ .')))
  
  rec <- rec %>%
    step_center( all_numeric(), - all_outcomes() ) %>%
    step_scale( all_numeric(), - all_outcomes() ) %>%
    step_YeoJohnson( all_numeric(), -all_outcomes() )
  
  prep_rec <- prep( rec, training = data )
  
  res_list <- list( df_yeojohnson = bake( prep_rec, data ),
                    lambdas = prep_rec$steps[[3]][["lambdas"]] )
}



# Load red wine data
df <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv",
         sep = ';')

# Get numeric column names but the quality
numeric_col_names <- df %>% 
    select( where(is.numeric), -quality ) %>% 
    names()


# Let's plot sulphates boxplot in order to see if
# there are univariate outliers
boxPlot(df, varx = 'sulphates', vary = NULL, vargrp = NULL,
        title = 'Sulphates distribution', xlab = 'sulphates', ylab = '' )

# As you see there are outliers, let's add a boolean 
# column to the dataframeindicating which row
# has a sulphate outlier
df <- add_is_outlier_IQR(df, col_name = 'sulphates')

# Let's plot the boxplot removing the initial outliers
df_no_outliers <- df %>% 
    filter( is_sulphates_outlier == 0 )

boxPlot(df_no_outliers, varx='sulphates', vary=NULL, vargrp = NULL,
        title='Sulphates distribution without outliers',
        xlab='sulphates', ylab=NULL)


# Let's now plot boxplots for each quality vote,
# removing the initial outliers
boxPlot(df_no_outliers, varx = 'quality', vary = 'sulphates', vargrp = 'quality',
        title = 'Sulphates distribution over quality', xlab = 'quality', ylab = 'sulphates' )


# Let's plot an histogram for each variable (no outliers)
df_no_outliers %>%
    select( numeric_col_names ) %>% 
    dataframeHist(bins = NULL)


# Let's apply Yeo-Johnson transformations
# in order to remove skewness
yeo_johnson_list <- df_no_outliers %>% 
    yeo_johnson_transf(target_name = 'quality')

df_transf <- yeo_johnson_list$df_yeojohnson


# Let's plot an histogram for all the transformed variables
# in order to check if skewness is decreased 
df_transf %>%
    select( numeric_col_names ) %>% 
    dataframeHist(bins = NULL)


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

distances


# Given a cutoff value associated with the statistical significance
# with which we want to determine outliers, we obtain the corresponding
# threshold value above which to consider an observation an outlier
cutoff <- 0.98
degrees_of_freedom <- ncol(data) # given by the number of variables (columns)

outliers_value_cutoff <- qchisq(cutoff, degrees_of_freedom) # threshold value


data <- data %>% 
    mutate(
        
        # Indicator column of outliers detected with Mahalanobis distance
        is_mahalanobis_outlier    = distances > outliers_value_cutoff,
        
        # Probability that an observation is an outlier not by chance
        mahalanobis_outlier_proba = pchisq(distances, ncol(data))
    )

data %>% 
  filter( is_mahalanobis_outlier == TRUE )

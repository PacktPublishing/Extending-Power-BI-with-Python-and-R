
library(readr)
library(dplyr)
library(purrr)
library(ggplot2)


violinPlot <- function(data, varx, vary, title, xlab, ylab, alpha=0.5, jitter=F) {
    
    if (jitter) {
        
        p <- ggplot(data=data, aes_string(x=varx, y=vary)) +
            geom_violin(show.legend = T) +
            geom_jitter(width=0.15, alpha=alpha) +
            labs(title=title, xlab=xlab, ylab=ylab) +
            theme(
                plot.title = element_text(size=24),
                axis.title = element_text(size=18),
                axis.text = element_text(size=14)
            )
        
    } else {
        
        p <- ggplot(data=data, aes_string(x=varx, y=vary)) +
            geom_violin(show.legend = T) +
            geom_boxplot(width=0.1, color="darkgrey", alpha=0.5) +
            labs(title=title, xlab=xlab, ylab=ylab) +
            theme(
                plot.title = element_text(size=24),
                axis.title = element_text(size=18),
                axis.text = element_text(size=14)
            )
        
    }
    
    return(p)
}

# Inspired by the following code:
# https://github.com/shakedzy/dython/blob/06aa19f3332de4f80478f5e8bf3ba868f7ddfb63/dython/nominal.py#L194
correlation_ratio <- function(categories, measurements, numeric_replace_value = 0) {
    
    measurements[is.na(measurements)] <- numeric_replace_value
    
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


# Load the Titanic disaster dataset
dataset_url <- 'http://bit.ly/titanic-data-csv'

tbl <- read_csv(dataset_url)
tbl


# Transform categorical variables in string columns
tbl <- tbl %>% 
    mutate( across(c('Survived', 'Pclass'), as.factor) )

tbl

# Let's calculate the Cramér's V coefficient for Survived and Pclass
rstatix::cramer_v(x=tbl$Survived, y=tbl$Pclass)

# Let's verify that Cramér's V is a symmetric function
rstatix::cramer_v(x=tbl$Survived, y=tbl$Pclass) == cramer_v(x=tbl$Pclass, y=tbl$Survived)


# You can also draw a mosaic plot for these variables
vcd::mosaic(~ Survived + Pclass, data = tbl,
            main = "Survived VS Passenger class", shade = TRUE)

# You can get a beautiful crosstab in this way
ct <- tbl %>%
    sjPlot::sjtab(fun = "xtab", var.labels=c("Survived", "Pclass"),
                  show.row.prc=T, show.col.prc=T, show.summary=T, show.exp=T, show.legend=T)

ct



# Take advantage of the asymmetry of Theil's U calculating it for the same variables.
# This is U(Survived|Pcalss) that is "U for Survived given Pclass"
DescTools::UncertCoef(tbl$Survived, tbl$Pclass, direction = 'row')

# Just check that the opposite direction gives you a different result
DescTools::UncertCoef(tbl$Pclass, tbl$Survived, direction = 'row')

# You can also show the distribution of a third dimension (in this case Survived)
# coloring half violin plot
violinPlot(data = tbl, varx = 'Pclass', vary = 'Age',
           title = 'Passenger Age VS Passenger Class',
           xlab = 'Pclass', ylab = 'Age', alpha = 0.4)

# Let's calculate the correlation ratio between the categorical variable Pclass and
# the numeric one Age
correlation_ratio( categories = tbl$Pclass, measurements = tbl$Age, numeric_replace_value = 0)

# Let's show how the correlation ratio will change changing the dispersion of observations for each category
t1 <- tibble(
    topic=c('Algebra','Algebra','Algebra','Algebra','Algebra','Geometry','Geometry','Geometry','Geometry','Statistics','Statistics','Statistics','Statistics','Statistics','Statistics'),
    score=c(45,70,29,15,21,40,20,30,42,65,95,80,70,85,73)
)


t1 %>%
    violinPlot(varx = 'topic', vary = 'score',
               title = 'η=0.84', xlab = '', ylab = '',
               alpha = 0.8, jitter = T)

t2 <- tibble(
    topic=c('Algebra','Algebra','Algebra','Algebra','Algebra','Geometry','Geometry','Geometry','Geometry','Statistics','Statistics','Statistics','Statistics','Statistics','Statistics'),
    score=c(36,36,36,36,36,33,33,33,33,78,78,78,78,78,78)
)

t2 %>%
    violinPlot(varx = 'topic', vary = 'score',
               title = 'η=0.84', xlab = '', ylab = '',
               alpha = 0.8, jitter = T)


# Create two data frames having the only column containing
# the tibble column names as values
row <- data.frame(row=names(tbl))
col <- data.frame(col=names(tbl))

# Create the cross join data frame from the previous two ones
ass <- tidyr::crossing(row, col)

# Add the corr column containing correlation values
corr_tbl <- ass %>% 
    mutate( corr = map2_dbl(row, col, ~ calc_corr(data = tbl, row_name = .x, col_name = .y, theil_uncert = T)) )

corr_tbl

# Let's plot an heatmap using the correlation tibble
corr_tbl %>% 
    ggplot( aes(x=row, y=col, fill=corr) ) +
    geom_tile() +
    geom_text(aes(row, col, label = round(corr, 2)), color = "white", size = 4)


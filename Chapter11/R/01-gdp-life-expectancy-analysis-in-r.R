
library(readr)
library(dplyr)
library(corrr)
library(ggplot2)


distPlot <- function(data, var, title, xlab, ylab, bins=100) {
    
    p <- ggplot( data=data, aes_string(x=var) ) + 
        geom_histogram( bins=bins, fill="royalblue3", color="steelblue1", alpha=0.9) +
        ggtitle(title) +
        xlab(xlab) +
        ylab(ylab) +
        theme( plot.title = element_text(size=15) )
        
    return(p)
}


scatterPlot <- function(data, varx, vary, title, xlab, ylab) {
    p <- ggplot( data=data, aes_string(x=varx, y=vary)) + 
        geom_point(
            color='steelblue1', fill='royalblue3',
            shape=21, alpha=0.8, size=3
        ) +
        ggtitle(title) +
        xlab(xlab) +
        ylab(ylab) +
        theme( plot.title = element_text(size=15) )
    
    return(p)
}



dataset_url <- 'http://bit.ly/gdp-life-expect-data'

tbl <- read_csv(dataset_url)
tbl

distPlot(data = tbl, var = 'lifeExp', title = 'Life Expectancy',
         xlab = 'Life Expectancy (years)', ylab = 'Frequency')

distPlot(data = tbl, var = 'gdpPercap', title = 'GDP / capita',
         xlab = 'GDP / capita ($)', ylab = 'Frequency')

scatterPlot(data = tbl, varx = 'lifeExp', vary = 'gdpPercap',
            title = 'Life Expectancy vs GDP/Capita', xlab = 'lifeExp', ylab = 'gdpPercap')


tbl %>% 
    select( lifeExp, gdpPercap ) %>% 
    correlate( method = 'pearson' )

tbl %>% 
    select( lifeExp, gdpPercap ) %>% 
    correlate( method = 'spearman' )

tbl %>% 
    select( lifeExp, gdpPercap ) %>% 
    correlate( method = 'kendall' )

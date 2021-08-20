
library(dplyr)
library(scales)
library(ggplot2)


circular_grouped_barplot <- function(data, grp_col_name, label_col_name, value_col_name, text_hjust=NULL){
  # Original code: https://www.r-graph-gallery.com/297-circular-barplot-with-groups/
  
  # Function used to rescale the values to a (0, 100) scale
  # for better understanding of the plot
  rescale100 <- function(x) rescale(x, to = c(0, 100))
  
  # Delay the execution of the function arguments.
  # They will be executed effectively using the bang bang (!!) syntax later on
  grp_var <- enquo(grp_col_name)
  label_var <- enquo(label_col_name)
  value_var <- enquo(value_col_name)
  
  # Transform data accordingly to have the plot
  data <- data %>% 
    mutate( 
      !!as_label(grp_var) := as.factor(!!grp_var),
      !!as_label(label_var) := as.factor(!!label_var),
      !!as_label(value_var) := rescale100(!!value_var) )
  
  # Set a number of 'empty bar' to add at the end of each group in data
  empty_bars <- 3
  
  # Create the empty dataframe to add to the source dataframe
  data_to_add <- data.frame( matrix(NA, empty_bars * nlevels(data[[as_label(grp_var)]]), ncol(data)) )
  colnames(data_to_add) <- colnames(data)
  data_to_add[[as_label(grp_var)]] <- rep(levels(data[[as_label(grp_var)]]), each = empty_bars)
  
  # Add the empty dataframe to the source one
  data <- rbind(data, data_to_add)
  # Reorder data by groups and values
  data <- data %>% arrange(!!grp_var, !!value_var)
  # Once ordered, add the bar identifier 'id'
  data$id <- seq(1, nrow(data))
  
  # Get the total number of bars
  number_of_bars <- nrow(data)
  
  # Subtract 0.5 from id because the label must have the angle of the center of the bars,
  # not extreme right(1) or extreme left (0)
  angles_of_bars <- 90 - 360 * (data$id - 0.5) / number_of_bars
  
  
  # Let's define the label dataframe starting from data
  label_data <- data
  label_data$hjust <- ifelse( angles_of_bars < -90, 1, 0)
  label_data$angle <- ifelse( angles_of_bars < -90, angles_of_bars + 180, angles_of_bars)
  
  # Let's prepare a data frame for group base lines
  base_data <- data %>% 
    group_by(!!grp_var) %>% 
    summarize(start = min(id),
              end = max(id) - empty_bars) %>% 
    rowwise() %>% 
    mutate(title = floor(mean(c(start, end)))) %>% 
    inner_join( label_data %>% select(id, angle),
                by = c('title' = 'id')) %>% 
    mutate( angle = ifelse( (angle > 0 & angle <= 90) |
                              (angle > 180 & angle <= 270),
                            angle-90, angle+90 ) )
  
  
  # If there are more than one group...
  if ( nrow(base_data) > 1 ) {
    
    # ...prepare a data frame for grid
    grid_data <- base_data
    grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
    grid_data$start <- grid_data$start - 1
    grid_data <- grid_data[-1,]
    
    # Prepare the plot adding also grids
    p <- data %>%
      ggplot(aes(x = id, y = !!value_var, fill = !!grp_var)) +
      
      # Add a barplot
      geom_bar(stat='identity', alpha=0.5) +
      
      # Add 100/75/50/25 indicators
      geom_segment(data=grid_data, aes(x = end, y = 100, xend = start, yend = 100),
                   colour = 'grey', alpha=1, size=0.3 , inherit.aes = FALSE ) +
      geom_segment(data=grid_data, aes(x = end, y = 80, xend = start, yend = 80),
                   colour = 'grey', alpha=1, size=0.3 , inherit.aes = FALSE ) +
      geom_segment(data=grid_data, aes(x = end, y = 60, xend = start, yend = 60),
                   colour = 'grey', alpha=1, size=0.3 , inherit.aes = FALSE ) +
      geom_segment(data=grid_data, aes(x = end, y = 40, xend = start, yend = 40),
                   colour = 'grey', alpha=1, size=0.3 , inherit.aes = FALSE ) +
      geom_segment(data=grid_data, aes(x = end, y = 20, xend = start, yend = 20),
                   colour = 'grey', alpha=1, size=0.3 , inherit.aes = FALSE ) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate('text', x = rep(max(data$id), 5), y = c(20, 40, 60, 80, 100),
               label = c('20', '40', '60', '80', 100) , color='grey', size=3,
               angle=0, fontface='bold', hjust=1)
    
  } else {
    # ... if there is only one group...
    
    # ... prepare the plot without the grids
    p <- data %>%
      ggplot(aes(x = id, y = !!value_var, fill = !!grp_var)) +
      
      # Add a barplot
      geom_bar(stat='identity', alpha=0.5) +
      
      # Add text showing the value of each 100/75/50/25 lines
      annotate('text', x = rep(max(data$id), 5), y = c(20, 40, 60, 80, 100),
               label = c('20', '40', '60', '80', 100) , color='grey', size=3,
               angle=0, fontface='bold', hjust=1)
    
  }
  
  # Now add all the other features to the plot
  
  # Number of distinct groups
  num_group_elements <- length(unique(data[[as_label(grp_var)]]))
  
  # Define text horizontal justification if not passed as parameter
  if (is.null(text_hjust)){
    text_horiz_justification <- rep.int(.5, num_group_elements)
  } else {
    text_horiz_justification <- text_hjust
  }
  
  p <- p +
    
    # The space between the x-axis and the lower edge of the figure will
    # implicitly define the width of the empty circle inside the plot 
    ylim(-120,120) +
    theme_minimal() +
    theme(
      legend.position = 'none',
      axis.text = element_blank(),
      axis.title = element_blank(),
      panel.grid = element_blank(),
      plot.margin = unit(rep(-1,4), 'cm') 
    ) +
    
    # Wrap all in a circle!
    coord_polar()
    
  # Now let's add bar labels appropriately rotated, base lines of groups and
  # group text labels appropriately rotated
  p <- p +
    
    # Add labels
    geom_text(data = label_data,
              aes(x = id, y = !!value_var + 10, label = !!label_var, hjust = hjust),
              color = 'black', fontface = 'bold', alpha = 0.6, size = 3,
              angle = label_data$angle, inherit.aes = FALSE) +
    
    # Add base lines of groups
    geom_segment(data = base_data, aes(x = start, y = -5, xend = end, yend = -5),
                 colour = 'black', alpha=0.8, size=0.6 , inherit.aes = FALSE ) +
    
    # Add groups text
    geom_text(data = base_data, aes(x = title, y = -14, label=!!grp_var, angle = angle),
              hjust=text_horiz_justification, colour = 'black', alpha=0.8, size=4,
              fontface='bold', inherit.aes = FALSE)
  
  return(p)
}


# # Uncomment if you're not running this code on Power BI
# library(readr)
# csv_full_path <- 'C:\\<your-path>\\Chapter15\\Scores.csv'
# dataset <- read_csv(file = csv_full_path)

# # You can also pass the text horizontal justification for the circular grouped barplot as a parameter.
# # The length of vectors must mach the length of speaker.characteristics
# circular_barplot_txthjust <- c(.5,.5,.5,.5)
dataset %>% 
  circular_grouped_barplot(grp_col_name = Characteristic, label_col_name = SpeakerName,
                           value_col_name = Votes)

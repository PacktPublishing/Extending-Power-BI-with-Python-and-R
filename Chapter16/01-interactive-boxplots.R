
# Load the dataset with proper column data types
folder <- r'{C:\<your-path>\Chapter14}'
init_path <- file.path(folder, r'{R\00-init-dataset.R}')

if(!exists('foo', mode='function')) source(init_path)


library(RColorBrewer)
library(ggplot2)
library(cowplot)


yeo_johnson_transf <- function(data) {
  require(recipes)
  
  rec <- recipe(data, as.formula(' ~ .'))
  
  rec <- rec %>%
    step_center( all_numeric() ) %>%
    step_scale( all_numeric() ) %>%
    step_YeoJohnson( all_numeric() )
  
  prep_rec <- prep( rec, training = data )
  
  res_list <- list( df_yeojohnson = bake( prep_rec, data ),
                    lambdas = prep_rec$steps[[3]][["lambdas"]] )
}


# This function allow you to keep the first max_factors-1 factors
# of a vector, combining the others ons into the new factor "others"
collapseFactors <- function(vec, max_factors = 8) {
  
  levs <- levels(vec)
  
  if (length(levs) >= max_factors) {
    
    collapsed_vec <- forcats::fct_collapse(vec, others = levs[max_factors:length(levs)])
    
  } else {
    
    collapsed_vec <- vec
    
  }
  
  return(collapsed_vec)
}


raincloudGrouped <- function(data, x, y, grp, y_transf_type, x_max_factors = 6, grp_max_factors = 4) {
  
  yeo_johnson_list <- data %>% 
    yeo_johnson_transf()
  
  transf_data <- yeo_johnson_list$df_yeojohnson
  
  # Categorical variable on x axis
  x_vec <- factor(data[[x]])
  x_vec <- collapseFactors(x_vec, max_factors = x_max_factors)
  
  data[[x]] <- x_vec
  
  # Numeric variable on y axis
  if (y_transf_type == 'yeo-johnson') {
    
    y_vec <- transf_data[[y]]
    y_label <- paste0('YeoJohnson(', y, ')')
    
  } else {
    
    y_vec <- data[[y]]
    y_label <- y
    
  }
  
  data[[y]] <- y_vec
  
  
  if (is.null(grp)) {
    
    title <- paste0(y_label, ' vs ', x, ' Raincloud Plot')
    
    praincloud <- ggplot(data, aes_string(x = x, y = y, fill = x, color = x)) +
      geom_boxplot(
        width = .12, 
        outlier.shape = NA,
        alpha = .4
      ) +
      geom_point(
        size = 1,
        alpha = .2,
        position = position_jitter(
          seed = 1, width = .06
        )
      ) +
      ggdist::stat_halfeye(
        adjust = .5,
        width = 0.6,
        .width = 0,
        justification = -.2, 
        point_colour = NA,
        alpha = .4) +
      scale_fill_brewer(palette = "Set1") +
      scale_color_brewer(palette = "Set1") +
      theme_minimal_hgrid(11, rel_small = 1) +
      theme(
        axis.text.x = element_text(angle = 90, hjust = 1)
      ) +
      labs(
        x = x,
        y = y_label,
        title = title
      )
    
  } else {
    
    title <- paste0(y_label, ' vs ', x, ' Raincloud Plot', ' by ', grp)
    
    grp_vec <- factor(data[[grp]])
    grp_vec <- collapseFactors(grp_vec, max_factors = grp_max_factors)
    
    data[[grp]] <- grp_vec
    
    praincloud <- ggplot(data, aes_string(x = x, y = y, fill = x)) +
      geom_boxplot(
        width = .12, 
        outlier.shape = NA,
        alpha = .4,
        position = position_dodge(0.5)
      ) +
      geom_point(
        aes_string(color = x_vec),
        size = 1,
        alpha = .2,
        position = position_jitterdodge(
          seed = 1, jitter.width = .06, dodge.width = .5
        )
      ) +
      ggdist::stat_halfeye(
        adjust = .5,
        width = 0.6,
        .width = 0,
        justification = -.2, 
        point_colour = NA,
        alpha = .4,
        position = position_dodge(0.5)) +
      scale_fill_brewer(palette = "Set1") +
      scale_color_brewer(palette = "Set1") +
      theme_minimal_hgrid(11, rel_small = 1) +
      theme(
        axis.text.x = element_text(angle = 90, hjust = 1),
        strip.background = element_rect(fill="grey85")) +
      labs(
        x = x,
        y = y_label,
        fill = x,
        colour = x,
        title = title
      ) +
      facet_wrap(as.formula(paste0('~', grp)), scale = 'free', nrow = 1)
    
  }
  
  return(praincloud)
  
}



tbl <- tbl %>% 
  mutate( Pclass = as.factor(Pclass) )


rc <- raincloudGrouped(tbl, 'Pclass', 'Fare', 'Sex', 'yeo-johnson')

pl <- plotly::ggplotly(rc, tooltip = c('x', 'y'))

pl

# If you want to save the widget in a self-contained HTML file:
#htmlwidgets::saveWidget(pl, 'boxplot.html')
               
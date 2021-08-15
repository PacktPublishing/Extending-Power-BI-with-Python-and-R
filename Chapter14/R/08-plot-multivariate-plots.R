
# Load the dataset with proper column data types
folder <- 'C:\\<your-folder>\\Chapter14'
init_path <- file.path(folder, 'R\\00-init-dataset.R')

if(!exists('foo', mode='function')) source(init_path)

library(recipes)
library(ggpubr)
library(cowplot)
library(RColorBrewer)
library(ggmosaic)


yeo_johnson_transf <- function(data) {
  
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


scatterMarginal <- function(data, x, y, grp, x_transf_type, y_transf_type, grp_max_factors = 4) {
  
  # Transform all numeric columns according to Yeo-Johnson
  yeo_johnson_list <- data %>% 
    yeo_johnson_transf()
  
  transf_data <- yeo_johnson_list$df_yeojohnson
  
  
  if (x_transf_type == 'yeo-johnson') {
    
    x_vec <- transf_data[[x]]
    x_label <- paste0('YeoJohnson(', x, ')')
  
  } else {
      
    x_vec <- data[[x]]
    x_label <- x
    
  }
  
  data[[x]] <- x_vec
  
  
  if (y_transf_type == 'yeo-johnson') {
    
    y_vec <- transf_data[[y]]
    y_label <- paste0('YeoJohnson(', y, ')')
  
  } else {
    
    y_vec <- data[[y]]
    y_label <- y
    
  }
  
  data[[y]] <- y_vec
  
  
  if (is.null(grp)) {
    
    title <- paste0(x_label, ' vs ', y_label, ' Scatterplot')
    
    cor_p <- stats::cor.test(x_vec, y_vec, method = "pearson", exact = FALSE)
    cor_s <- stats::cor.test(x_vec, y_vec, method = "spearman", exact = FALSE)
    cor_k <- stats::cor.test(x_vec, y_vec, method = "kendall", exact = FALSE)
    
    decimals <- 3
    decimals_p <- 3
    
    stat_label <-
      base::substitute(
        paste(italic('r'), ' = ', p_estimate, ', ', italic('p'), ' = ', p_pvalue, '  |  ',
              italic('rho'), ' = ', s_estimate, ', ', italic('p'), ' = ', s_pvalue, '  |  ',
              italic('tau'), ' = ', k_estimate, ', ', italic('p'), ' = ', k_pvalue
        ),
        list(
          p_estimate = ggstatsplot::specify_decimal_p(cor_p$estimate, decimals),
          p_pvalue = ggstatsplot::specify_decimal_p(cor_p$p.value, k = decimals_p, p.value = TRUE),
          s_estimate = ggstatsplot::specify_decimal_p(cor_s$estimate, decimals),
          s_pvalue = ggstatsplot::specify_decimal_p(cor_s$p.value, k = decimals_p, p.value = TRUE),
          k_estimate = ggstatsplot::specify_decimal_p(cor_k$estimate, decimals),
          k_pvalue = ggstatsplot::specify_decimal_p(cor_k$p.value, k = decimals_p, p.value = TRUE)
        )
      )
    
    p1 <- data %>%
      ggplot(aes_string(x = x, y = y)) +
      geom_point(color = '#377EB8', alpha = .4) +
      geom_smooth(method = 'lm') +
      theme_pubr() +
      theme(legend.position='left') +
      labs(
        x = x_label,
        y = y_label,
        title = title,
        subtitle = stat_label
      )
    
    pf <- ggExtra::ggMarginal(p1, type="histogram", color = '#E41A1C', fill = '#E41A1C', alpha = .4)
    
  } else {
    
    title <- paste0(x_label, ' vs ', y_label, ' Scatterplot by ', grp)
    
    grp_vec <- factor(data[[grp]])
    grp_vec <- collapseFactors(grp_vec, max_factors = grp_max_factors)
    
    data[[grp]] <- grp_vec
    
    
    p1 <- data %>%
      ggplot(aes_string(x = x, y = y, color = grp)) +
      geom_point(alpha = .4) +
      geom_smooth(method = 'lm') +
      scale_color_brewer(palette = "Set1") +
      theme_pubr() +
      theme(legend.position='left') +
      labs(
        x = x_label,
        y = y_label,
        color = grp,
        title = title
      )
      
    
    pf <- ggExtra::ggMarginal(p1, type="histogram", groupColour = TRUE, groupFill = TRUE, alpha = .4)
    
  }
  
  return(pf)
  
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


mosaicGrouped <- function(data, cat1, cat2, grp, cat1_max_factors = 8, cat2_max_factors = 5, grp_max_factors = 4) {
  
  # Categorical variable on x axis
  cat1_vec <- factor(data[[cat1]])
  cat1_vec <- collapseFactors(cat1_vec, max_factors = cat1_max_factors)
  data[[cat1]] <- cat1_vec
  
  cat2_vec <- factor(data[[cat2]])
  cat2_vec <- collapseFactors(cat2_vec, max_factors = cat2_max_factors)
  data[[cat2]] <- cat2_vec
  
  
  if (is.null(grp)) {
    
    title <- paste0(cat2, ' vs ', cat1, ' Mosaic Plot')
    
    pmosaic <- ggplot(data = data) +
      geom_mosaic(aes_string(x = paste0("product(", cat1, ")"), fill = cat2), alpha = .5) +
      theme_mosaic() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      scale_fill_brewer(palette = "Set1") +
      labs(
        x = cat1,
        y = cat2,
        fill = cat2,
        title = title
      )
    
  } else {
    
    title <- paste0(cat2, ' vs ', cat1, ' Mosaic Plot', ' by ', grp)
    
    grp_vec <- factor(data[[grp]])
    grp_vec <- collapseFactors(grp_vec, max_factors = grp_max_factors)
    
    data[[grp]] <- grp_vec
    
    pmosaic <- ggplot(data = data) +
      geom_mosaic(aes_string(x = paste0("product(", cat1, ")"), fill = cat2), alpha = .5) +
      theme_mosaic() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      scale_fill_brewer(palette = "Set1") +
      labs(
        x = cat1,
        y = cat2,
        fill = cat2,
        title = title
      ) +
      facet_wrap(as.formula(paste0('~', grp)), scale = 'free', nrow = 1)
    
  }
  
}



# # Uncomment it you're not running this script in Power BI
# # First run the code of the file '05-create-multivariate-objects.R'.
# # Then run the following line:
# dataset <- multivariate_df

row <- 1

x <- (dataset %>% pull('x'))[row]
x_transf_type <- (dataset %>% pull('x_transf_type'))[row]
y <- (dataset %>% pull('y'))[row]
y_transf_type <- (dataset %>% pull('y_transf_type'))[row]
cat1 <- (dataset %>% pull('cat1'))[row]
cat2 <- (dataset %>% pull('cat2'))[row]
grp <- (dataset %>% pull('grp'))[row]

if (grp == '<none>') {
  grp <- NULL
}

# # Uncomment for debug
# cat1 <- 'Pclass'
# cat2 <- 'SibSp'
# x <- 'Age'
# x_transf_type = 'standard'
# y <- 'Fare'
# y_transf_type = 'yeo-johnson'
# grp <- NULL


p1 <- scatterMarginal(tbl, x, y, grp, x_transf_type, y_transf_type)

p2 <- mosaicGrouped(tbl, cat1, cat2, grp)

p3 <- raincloudGrouped(tbl, cat1, y, grp, y_transf_type)


right_grid_col <- plot_grid(p2, p3, ncol = 1)
plot_grid(p1, right_grid_col, ncol = 2)

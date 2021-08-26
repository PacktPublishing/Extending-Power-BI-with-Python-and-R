# # Save the content of all the environment when the custom visual is used in Power BI.
# # This way you can load the same file in RStudio to debug any issue.
# fileRda = "C:/Users/<your-username>/Power-BI-Custom-Visuals/tempData.Rda"
# if(file.exists(dirname(fileRda)))
# {
#   if(Sys.getenv("RSTUDIO")!="")
#     load(file= fileRda)
#   else
#     save(list = ls(all.names = TRUE), file=fileRda)
# }

source('./r_files/flatten_HTML.r')

############### Library Declarations ###############
libraryRequireInstall("ggplot2");
libraryRequireInstall("plotly")
####################################################

################### Actual code ####################
library(RColorBrewer)
library(cowplot)
library(dplyr)


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


boxplotsGrouped <- function(data, x, y, grp, y_transf_type, x_max_factors = 6, grp_max_factors = 4) {
  
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

        title <- paste0(y_label, ' vs ', x)

        praincloud <- ggplot(data, aes_string(x = x, y = y, fill = x, color = x)) +
            geom_boxplot(
                width = .12,
                outlier.color = NA,
                outlier.size = 0,
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
            scale_fill_brewer(palette = "Set1") +
            scale_color_brewer(palette = "Set1") +
            theme_minimal_hgrid(11, rel_small = 1) +
            theme(
                axis.text.x = element_text(angle = 90, hjust = 1),
                legend.position="none"
            ) +
            labs(
                x = x,
                y = y_label,
                title = title
            )

    } else {

    title <- paste0(y_label, ' vs ', x, ' by ', grp)

    grp_vec <- factor(data[[grp]])
    grp_vec <- collapseFactors(grp_vec, max_factors = grp_max_factors)

    data[[grp]] <- grp_vec

    praincloud <- ggplot(data, aes_string(x = x, y = y, fill = x)) +
        geom_boxplot(
            width = .12,
            outlier.color = NA,
            outlier.size = 0,
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
        scale_fill_brewer(palette = "Set1") +
        scale_color_brewer(palette = "Set1") +
        theme_minimal_hgrid(11, rel_small = 1) +
        theme(
            axis.text.x = element_text(angle = 90, hjust = 1),
            strip.background = element_rect(fill="grey85"),
            legend.position="none"
        ) +
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


y_transf_name <- 'standard'

if(exists("settings_variable_params_y_transf_name")){
  y_transf_name <- as.character(settings_variable_params_y_transf_name)
}

is_valid_plot <- FALSE


if (exists('x') & exists('y')) {

    categ_var_name <- names(x)
    value_var_name <- names(y)

    dataset <- data.frame(
        x = x,
        y = y
    )
    

    if (exists('grp')) {

        grp_var_name   <- names(grp)

        dataset <- cbind(dataset, grp = grp)

    } else {
        grp_var_name   <- NULL
    }

    is_valid_plot <- TRUE
}


if (is_valid_plot) {
    rc <- boxplotsGrouped(dataset, categ_var_name, value_var_name, grp_var_name, y_transf_name)
} else {
    rc <- ggplot() + theme_minimal() # Empty plot
}


p <- plotly::ggplotly(rc, tooltip = c('x', 'y'))


# Removing some Plotly modebar icons 
disabledButtonsList <- list('toImage', 'sendDataToCloud', 'zoom2d', 'pan', 'pan2d', 'select2d', 'lasso2d', 'hoverClosestCartesian', 'hoverCompareCartesian')
p$x$config$modeBarButtonsToRemove = disabledButtonsList
p <- config(p, staticPlot = FALSE, editable = FALSE, sendData = FALSE, showLink = FALSE,
            displaylogo = FALSE,  collaborate = FALSE, cloud=FALSE)

# Workaround to hide outliers in Plotly
hideOutliers <- function(x) {  
  if (x$hoverinfo == 'y') {  
    x$marker = list(opacity = 0)
    x$hoverinfo = NA    
  }  
  return(x)  
}

p[["x"]][["data"]] <- purrr::map(p[["x"]][["data"]], ~ hideOutliers(.))

####################################################

############# Create and save widget ###############
internalSaveWidget(p, 'out.html');
####################################################

################ Reduce paddings ###################
ReadFullFileReplaceString('out.html', 'out.html', ',"padding":[0-9]*,', ',"padding":0,')
####################################################

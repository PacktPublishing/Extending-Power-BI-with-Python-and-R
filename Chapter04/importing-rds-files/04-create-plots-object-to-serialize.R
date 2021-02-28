
library(tidyverse)
library(timetk)

# Load the 'population' data set provided
# by the tidyr package
data("population")

# Let's nest the 'year' and 'population' data
# into another tibble for each country
nested_population_tbl <- population %>% 
  tidyr::nest( demographic_data = -country )


# Let's try to plot the population growth time series for Sweden
selected_country <- "Sweden"
  
nested_population_tbl %>% 

  # Get the row related to the selected country
  filter( country == selected_country ) %>% 
  
  # Get the content of 'demographic_data' for
  # that row. Note that it is a list
  pull( demographic_data ) %>%
  
  # Extract the 'demographic_data' tibble from
  # the list (it has only 1 element)
  pluck(1) %>% 
  
  # Now plot the time series declaring the date variable
  # and the value one. 
  timetk::plot_time_series(
    .date_var = year,
    .value = population,
    .title = paste0("Global population of ", selected_country),
    
    .smooth = FALSE,     # --> remove the smooth line
    .interactive = FALSE # --> generate a static plot
  )


# Let's generate a time series plot as shown above
# for each selected country and persist the result
# in the 'plot' column into the nested population tibble
nested_population_plots_tbl <- nested_population_tbl %>%

  # Select a subset of countries
  filter( country %in% c("Italy", "Sweden", "France", "Germany") ) %>%

  # Add a new column called 'plot' applying the plot_time_series
  # function to the values of the demographic_data tibble (.x)
  # for each country (.y) in the 'country' field.
  # Do this thanks to the map2 function.
  mutate(
    plot = map2( demographic_data, country, ~ timetk::plot_time_series(
      .data = .x,
      .date_var = year,
      .value = population,
      .title = paste0("Global population of ", .y),
      .smooth = FALSE,
      .interactive = FALSE) )
  ) %>%

  # Return just the 'country' and 'plot' columns.
  select( country, plot )


# Now extract the named list of plots for each country from the nested tibble.
plots_lst <- nested_population_plots_tbl %>% 
  
  # converts two-column data frames to a named list, using
  # the first column as name and the second column as value
  deframe()


# Serialize the list of plots
saveRDS(plots_lst, "plots_lst.rds")



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


# Now extract the list of plots from the nested tibble.
# The index of list items corresponds to the country_id values
# into the selected countries tibble.
plot_lst <- nested_population_plots_tbl$plot

# Serialize the list of plots
saveRDS(plot_lst, "plot_lst.rds")


# Let's build a tibble having the name of the selected countries as
# a column and then their position index (alias row number) as a
# column.
selected_countries_tbl <- nested_population_plots_tbl["country"] %>% 
  
  # Transform the row numbers (chars) in the 'country_id' column.
  rownames_to_column( var = "country_id" ) %>% 
  
  # Cast the 'country_id' column as integers.
  mutate( country_id = as.integer(country_id) )

# Serialize the selected countries tibble
saveRDS(selected_countries_tbl, "selected_countries_tbl.rds")

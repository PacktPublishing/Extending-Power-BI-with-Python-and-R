
library(tidyverse)

project_folder <- "C:/<your>/<absolute>/<project_folder>/<path>"


# Deserialize the plots list.
deserialized_lst <- readRDS( file.path(project_folder, "plot_lst.RDS") )

# Get the country names from the 'keys' of the plots named list
selected_countries_tbl <- names(deserialized_lst)


# Select a country, get its country id from the tibble.
selected_country <- "Italy"

country_id <- selected_countries_tbl %>% 
  filter( country == selected_country ) %>% 
  pull( country_id )

# Use the country id as index of the
# plots list and extract the time series
# associated to the selected country.
population_plot <- deserialized_lst %>% 
  pluck( country_id )

# Plot the time series (it's a ggplot visual)
population_plot

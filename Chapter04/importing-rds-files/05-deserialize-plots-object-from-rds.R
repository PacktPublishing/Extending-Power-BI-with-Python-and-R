
library(tidyverse)

project_folder <- "D:\\LZavarella\\OneDrive\\MVP\\Packt Book\\Code\\Extending-Power-BI-with-Python-and-R\\Chapter04\\importing-rds-files"


# Deserialize the plots list.
deserialized_lst <- readRDS( file.path(project_folder, "plot_lst.RDS") )

# Deserialize the selected countries tibble.
selected_countries_tbl <- readRDS( file.path(project_folder, "selected_countries_tbl.rds") )


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

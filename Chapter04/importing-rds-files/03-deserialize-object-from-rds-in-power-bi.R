library(tidyverse)

project_folder <- "C:/<your>/<absolute>/<project_folder>/<path>"

deserialized_tbl <- readRDS( file.path(project_folder, "nested_population_tbl.RDS") )

# Let's extract the demographic
# tibble for the Sweden
sweden_population_tbl <- deserialized_tbl %>%
  
  # Get the row related to the country "Sweden"
  filter( country == "Sweden" ) %>% 
  
  # Get the content of 'demographic_data' for
  # that row. Note that it is a list
  pull( demographic_data ) %>%
  
  # Extract the 'demographic_data' tibble from
  # the list (it has only 1 element)
  pluck(1)

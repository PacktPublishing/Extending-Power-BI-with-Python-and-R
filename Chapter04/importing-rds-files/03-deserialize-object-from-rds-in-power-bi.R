library(tidyverse)

project_folder <- "C:/<your>/<absolute>/<project_folder>/<path>"

deserialized_tbl <- readRDS( file.path(project_folder, "nested_population_tbl.RDS") )

sweden_population_tbl <- deserialized_tbl %>% 
  filter( country == "Sweden" ) %>% 
  pull( demographic_data ) %>%
  pluck(1)

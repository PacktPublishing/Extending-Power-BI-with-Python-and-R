
deserialized_tbl <- readRDS("nested_population_tbl.RDS")

# Let's take a look at the deserialized tibble
deserialized_tbl


# Let's do an example of extracting a demografic
# tibble for a region (Sweden)
sweden_population_tbl <- deserialized_tbl %>% 
  
  # Get the row related to the country "Sweden"
  filter( country == "Sweden" ) %>% 
  
  # Get the content of 'demografic_data' for
  # that row. Note that it is a list
  pull( demografic_data ) %>%
  
  # Extract the 'demografic_data' tibble from
  # the list (it has only 1 element)
  pluck(1)
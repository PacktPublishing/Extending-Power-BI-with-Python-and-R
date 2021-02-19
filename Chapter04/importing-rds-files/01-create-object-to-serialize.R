
library(tidyverse)

# Load the 'population' data set provided
# by the tidyr package
data("population")

# Let's have a look at the tibble
population

# Let's have a look at the countries
population %>% 
  
  # Get only the distinct values of 'country'
  # The result is still a tibble of one column
  distinct(country) %>% 
  
  # "Detach" the distinct column from the tibble
  # and make it a vector
  pull()

# Let's nest the 'year' and 'population' data
# into another tibble for each country
nested_population_tbl <- population %>% 
  tidyr::nest( demographic_data = -country )

# Let's have a look to the tibble.
# Note that the nested column is
# a list of tibbles
nested_population_tbl

# Let's serialize the nested population tibble
# in a RDL file in order to share it
saveRDS(nested_population_tbl, "nested_population_tbl.rds")


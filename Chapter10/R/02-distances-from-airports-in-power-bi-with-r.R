
library(readr)
library(dplyr)
library(purrr)
library(geosphere)


airportLongLatVec <- function(df, iata) {
    ret_vec <- df %>% 
        filter( iata_code == iata ) %>% 
        select( longitude, latitude ) %>% 
        unlist()    
    
    return(ret_vec)
}

airports_tbl <- read_csv(r'{D:\<your-path>\Chapter10\airport-codes.csv}')

# Coordinates are saved as a string, so we have to split them into two new columns
airports_tbl <- airports_tbl %>% 
    tidyr::separate(
        col = coordinates,
        into = c('longitude', 'latitude'),
        sep = ', ',
        remove = TRUE,
        convert = TRUE )
airports_tbl


jfk_coordinates <- airportLongLatVec(airports_tbl, 'JFK')
lga_coordinates <- airportLongLatVec(airports_tbl, 'LGA')


# Using the Mean (spherical) earth radius R1 (in meters)
# as the default in the PyGeodesy Python package
# (reference: https://en.wikipedia.org/wiki/Earth_radius#Published_values)
hotels_df <- dataset %>% 
    mutate(
        p1 = map2(longitude, latitude, ~ c(.x, .y))
    ) %>% 
    mutate(
        haversineDistanceFromJFK = map_dbl(p1, ~ distHaversine(p1 = .x, p2 = jfk_coordinates, r = 6371008.771415)),
        karneyDistanceFromJFK = map_dbl(p1, ~ distGeo(p1 = .x, p2 = jfk_coordinates)),
        haversineDistanceFromLGA = map_dbl(p1, ~ distHaversine(p1 = .x, p2 = lga_coordinates, r = 6371008.771415)),
        karneyDistanceFromLGA = map_dbl(p1, ~ distGeo(p1 = .x, p2 = lga_coordinates))
    ) %>%
    select( -p1 )


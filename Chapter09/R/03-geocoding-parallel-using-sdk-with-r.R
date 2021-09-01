
library(readr)
library(dplyr)
library(stringr)
library(furrr)
library(tictoc)
library(tidygeocoder)
library(jsonlite)


bing_geocode_via_address <- function(address) {
    
    details_tbl <- geo(address, method = 'bing', full_results = TRUE)
        
    details_lst <- list(
        formattedAddress = details_tbl$bing_address.formattedAddress,
        lat = details_tbl$point.coordinates[[1]][1],
        lng = details_tbl$point.coordinates[[1]][2],
        details_tbl = toJSON(details_tbl)
    )

    return( details_lst )
}


####################################################################################################
# To be set up separately for security reasons
####################################################################################################
Sys.setenv(BINGMAPS_API_KEY = "<your-api-key>")
####################################################################################################

tbl_orig <- read_csv(r'{D:\LZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter09\geocoding_test_data.csv}',
                    locale = locale(encoding = 'ISO-8859-1'))

tbl <- tbl_orig %>% select('full_address','lat_true','lon_true')

n_cores <- availableCores() - 1
plan(cluster, workers = n_cores)

tic()
tbl_enriched <- tbl %>%
    pull( full_address ) %>% 
    future_map_dfr( ~ bing_geocode_via_address(.x) ) %>% 
    bind_cols( tbl, . )
toc()


tbl_enriched


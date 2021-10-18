
library(httr)
library(jsonlite)
library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(tictoc)


bing_geocode_via_address <- function(address) {
    
    encoded_address <- RCurl::curlPercentEncode(address)
    
    full_url <- str_glue('{base_url}query={encoded_address}?key={AUTH_KEY}')
    
    r <- GET(full_url)
    
    if (r$status_code == 200) {
        
        details_content <- content( r, "text", encoding = "UTF-8" )
        
        details_lst <- tryCatch({
            
            details_json <- fromJSON(details_content)
            
            # number of resources found, used as index to get the
            # latest resource
            num_resources = details_json$resourceSets$estimatedTotal
            
            details_lst <- list(
                numOfResources = num_resources,
                formattedAddress = details_json$resourceSets$resources[[1]]$address$formattedAddress[num_resources],
                lat = details_json$resourceSets$resources[[1]]$point$coordinates[[num_resources]][1],
                lng = details_json$resourceSets$resources[[1]]$point$coordinates[[num_resources]][2],
                statusDesc = details_json$statusDescription
            )
            
        }, error = function(err) {
            
            details_lst <- list(
                numOfResources = 0,
                formattedAddress = NA,
                lat = NA,
                lng = NA,
                statusDesc = str_glue('ERROR: {err}')
            )
            
            return(details_lst)
            
        })
        
        details_lst$statusCode <- r$status_code
        details_lst$text <- details_content
        details_lst$url <- r$url
        
        
    } else {
        
        details_lst <- list(
            numOfResources = 0,
            formattedAddress = NA,
            lat = NA,
            lng = NA,
            statusDesc = str_glue('ERROR: {err}'),
            statusCode = r$status_code,
            text = details_content,
            url = r$url
        )
        
    }
    

    return( details_lst )
}


####################################################################################################
# To be set up separately for security reasons
####################################################################################################
Sys.setenv(BINGMAPS_API_KEY = "<your-api-key>")
####################################################################################################

base_url= "http://dev.virtualearth.net/REST/v1/Locations/"
AUTH_KEY = Sys.getenv('BINGMAPS_API_KEY')


tbl_orig <- read_csv(r'{D:\<your-path>\Chapter09\geocoding_test_data.csv}',
                    locale = locale(encoding = 'ISO-8859-1'))

tbl <- tbl_orig %>% select('full_address','lat_true','lon_true')

tic()
tbl_enriched <- tbl %>%
    pull( full_address ) %>% 
    map_dfr( ~ bing_geocode_via_address(.x) ) %>% 
    bind_cols( tbl, . )
toc()


tbl_enriched


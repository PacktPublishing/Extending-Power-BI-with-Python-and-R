
library(stringr)
library(spacyr)
library(dplyr)
library(purrr)


generateToken <- function(len, num_tokens = NULL) {
  if (is.null(num_tokens)) {
    nt <- 1
  } else {
    nt <- num_tokens
  }
  
  stringi::stri_rand_strings(n = nt, length = len, pattern = '[A-Z0-9]')
}

anonymizeEmails <- function(text_to_anonymize) {
  
  matched_emails <- spacy_parse(text_to_anonymize, pos = TRUE, additional_attributes = c("like_email")) %>%
    filter( like_email == TRUE ) %>% 
    pull(token)
  
  if (length(matched_emails) > 0) {
    str_replace_all( text_to_anonymize, setNames(nm=matched_emails,
                                                 # replicate(length(matched_emails),
                                                 #           InternetProvider$new(locale = "en_US")$email(),
                                                 #           simplify=TRUE))
                                                 generateToken(len = 20, num_tokens = length(matched_emails)))
                    )
  } else {
    return(text_to_anonymize)
  }
  
}


anonymizeNames <- function(text_to_anonymize) {
  
  matched_patterns <- spacy_parse(text_to_anonymize, pos = TRUE, entity = TRUE) %>% 
    entity_consolidate(concatenator = " ") %>% 
    filter( entity_type == "PERSON" ) %>% 
    mutate( pattern = str_replace(token, pattern = r"{^([^\s]+).*?([^\s]+)$}", replacement = r"{\1.*?\2}") ) %>% 
    pull(pattern)
  
  if (length(matched_patterns) > 0) {
    str_replace_all( text_to_anonymize, setNames(nm=matched_patterns,
                                                 #ch_name(n = length(matched_patterns), locale = "en_US"))
                                                 generateToken(len = 20, num_tokens = length(matched_patterns)))
                     )
  } else {
    return(text_to_anonymize)
  }
  
}


# For testing purpose you can load the Excel content directly here
# # Load the Excel content in a dataframe
# library(readxl)
# dataset <- read_xlsx(r"{D:\LZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter06\CustomersCreditCardAttempts.xlsx}")

df <- dataset


spacy_initialize(
  model = "en_core_web_lg",
  condaenv = r"{C:\Users\LZavarella\miniconda3\envs\presidio_env}",
  entity = TRUE
)


df <- df %>% 
  mutate(
    Name  = map_chr( Name, .f = ~ anonymizeNames(.x)),
    Email = map_chr( Email, .f = ~ anonymizeEmails(.x)),
    Notes = map_chr( Notes, .f = ~ anonymizeEmails(.x))
  ) %>% 
  mutate(
    Notes = map_chr( Notes, .f = ~ anonymizeNames(.x))
  )


# # Show both the dataframes
# dataset
# df




library(stringr)
library(spacyr)
library(dplyr)
library(purrr)
library(charlatan)

anonymizeEmails <- function(text_to_anonymize, country) {
  
  locale <- faker_locales_dict[[country]]
  
  matched_results <- spacy_parse(text_to_anonymize, pos = TRUE, additional_attributes = c("like_email")) %>%
    filter( like_email == TRUE ) %>% 
    pull(token)
  
  matched_emails <- list()
  for (email in matched_results) {
    
    if (!email %in% names(emails_lst)) {
      
      fake_email <- InternetProvider$new(locale = locale)$email()
      
      while ( (fake_email %in% emails_lst) | (fake_email %in% names(emails_lst)) ) {
        fake_email <- InternetProvider$new(locale = locale)$email()
      }
      
      emails_lst[email] <- fake_email
      matched_emails[email] <- fake_email
      
    } else {
      
      fake_email <- emails_lst[[email]]
      matched_emails[email] <- fake_email
      
    }
  }
  
  anonymized_result <- text_to_anonymize
  
  for (email in names(matched_emails)) {
    anonymized_result <- str_replace(anonymized_result, email, matched_emails[[email]])
  }
  
  return(anonymized_result)
  
}


anonymizeNames <- function(text_to_anonymize, country) {
  
  locale <- faker_locales_dict[[country]]
  
  matched_patterns <- spacy_parse(text_to_anonymize, pos = TRUE, entity = TRUE) %>% 
    entity_consolidate(concatenator = " ") %>% 
    filter( entity_type == "PERSON" ) %>% 
    mutate( pattern = str_replace(token, pattern = r"{^([^\s]+).*?([^\s]+)$}", replacement = r"{\1.*?\2}") ) %>% 
    pull(pattern)
  
  matched_results <- str_match_all(text_to_anonymize, matched_patterns) %>% 
    map_chr( ~ .x[1,1] )
  
  matched_names <- list()
  for (name in matched_results) {
    
    if (!name %in% names(names_lst)) {
      
      fake_name <-  ch_name(n = 1, locale = locale)
      
      while ( (fake_name %in% names_lst) | (fake_name %in% names(names_lst)) ) {
        fake_name <- ch_name(n = 1, locale = locale)
      }
      
      names_lst[name] <- fake_name
      matched_names[name] <- fake_name
      
    } else {
      
      fake_name <- names_lst[[name]]
      matched_names[name] <- fake_name
      
    }
  }
  
  anonymized_result <- text_to_anonymize
  
  for (name in names(matched_names)) {
    anonymized_result <- str_replace(anonymized_result, name, matched_names[[name]])
  }
  
  return(anonymized_result)
  
}


spacy_initialize(
  model = "en_core_web_lg",
  condaenv = r"{C:\Users\<your-user-name>\miniconda3\envs\presidio_env}",
  entity = TRUE
)

# Define locale and language dictionaries
faker_locales_dict <- list(
  'UNITED STATES' = 'en_US', 'ITALY' = 'it_IT', 'GERMANY' = 'de_DE'
)

# Load mapping lists from RDS files if they exist, otherwise create empty lists
rds_path <- r'{D:\<your-path>\Chapter06\RDSs}'

emails_list_rds_path <- file.path(rds_path, 'emails_list.rds')
names_list_rds_path <- file.path(rds_path , 'names_list.rds')

if (file.exists(emails_list_rds_path)){
  emails_lst <- readRDS(emails_list_rds_path)
} else {
  emails_lst <- list()
}

if (file.exists(names_list_rds_path)){
  names_lst <- readRDS(names_list_rds_path)
} else {
  names_lst <- list()
}


# For testing purpose you can load the Excel content directly here
# # Load the Excel content in a dataframe
# library(readxl)
# dataset <- read_xlsx(r"{D:\<your-path>\Chapter06\CustomersCreditCardAttempts.xlsx}")

df <- dataset

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

# Write emails and names lists to RDS files
saveRDS(emails_lst, emails_list_rds_path)
saveRDS(names_lst, names_list_rds_path)

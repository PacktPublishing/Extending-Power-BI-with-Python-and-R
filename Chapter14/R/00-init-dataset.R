library(readr)
library(dplyr)

# Ricordarsi di menzionare tk_augment_timeseries_signature di timetk

#-- Change this section to load your data ----

# Load your dataset
dataset_url <- 'http://bit.ly/titanic-dataset-csv'
src_tbl <- read_csv(dataset_url)

vars_to_drop <- c('PassengerId')
categorical_vars <- c('Sex', 'Ticket', 'Cabin', 'Embarked')
integer_vars <- c('Survived', 'Pclass', 'SibSp', 'Parch')


#-- DO NOT CHANGE ----

tbl <- src_tbl %>% 
  mutate( 
    across(categorical_vars, as.factor),
    across(integer_vars, as.integer)
  ) %>% 
  select( -all_of(vars_to_drop) )

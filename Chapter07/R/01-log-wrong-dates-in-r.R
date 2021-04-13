library(readr)
library(dplyr)

dataset %>%
  filter( isDateValidFromRegex == 0 ) %>%
  write_csv( r'{D:\<your-path>\Chapter07\R\wrong-dates.csv}', eol = '\r\n' )
  

df <- dataset %>%
  filter( isDateValidFromRegex == 1 )

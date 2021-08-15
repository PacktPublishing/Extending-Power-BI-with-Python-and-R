
library(tidyr)
library(ggplot2)
library(DataExplorer)
library(summarytools)

# Load the dataset with proper column data types
init_path <- r'{C:\<your-folder>\Chapter14\R\00-init-dataset.R}'
if(!exists('foo', mode='function')) source(init_path)


# Basic dataset info
basic_info_tbl <- introduce(tbl) %>% 
  pivot_longer(cols = everything(), names_to = 'attribute', values_to = 'value')

duplicated_rows_num <- (
  
    # From the number of total rows...
    basic_info_tbl %>% 
      filter( attribute == 'rows' ) %>% 
      pull()
  ) - (
    # ... subtract the number of distinct rows
    tbl %>% 
      distinct() %>% 
      tally() %>% 
      pull()
  )

basic_info_tbl <- basic_info_tbl %>% 
  bind_rows(
    tibble(attribute = 'duplicated_rows', value = duplicated_rows_num)
  )

basic_info_tbl


# Dataset summary
summary_tbl <- data.frame(dfSummary(tbl, graph.col = FALSE, varnumbers = FALSE,
                                    na.col = TRUE, max.distinct.values = 20)) %>% 
  
  # Remove a backslash that remains after the conversion to dataframe
  mutate_if(is.character, 
            stringr::str_replace_all, pattern = '\\\\', replacement = '') %>% 
  
  # Rename uncommon column names after the conversion
  rename( 'Stats Values' = 'Stats...Values', 'Freq of Valid' = 'Freqs....of.Valid.' ) %>% 
  
  # Add the column of unique valid values (not null)
  bind_cols(
    tbl %>% 
      summarise_all( ~n_distinct(. ,na.rm = TRUE) ) %>% 
      pivot_longer(cols = everything(), names_to = 'Variable', values_to = 'Unique Valid') %>% 
      mutate( 'Unique Valid' = paste0(`Unique Valid`, ' distinct values') ) %>% 
      select( 'Unique Valid' )
  ) %>% 
  
  # Relocate the unique values column properly
  relocate( 'Unique Valid', .before = 'Freq of Valid')
  


# Enriched descriptive statistics of numeric columns
numeric_vars_descr_stats_tbl <- tbl %>% 
  descr() %>% 
  tb() %>% 
  select( -se.skewness, -n.valid, -pct.valid )

numeric_vars_descr_stats_tbl


sample_tbl <- tbl %>% head(100)


library(dplyr)
library(tidymodels)

from_byte_string = function(x) {
  xcharvec = strsplit(x, " ")[[1]]
  xhex = as.hexmode(xcharvec)
  xraw = as.raw(xhex)
  unserialize(xraw)
}


getModelFromStringSerializedDataframe <- function(str_serialized_df) {
  
  # Sort the contents of the dataframe by model_id and chunk_id, to ensure that
  # the string chunks are sorted correctly and ready to be deserialized
  model_vct <- str_serialized_df %>%
    arrange(model_id, chunk_id) %>%
    pull(model_str)
  
  # Merge the chunks
  model_vct_str <- paste( model_vct, collapse = "" )
  
  # Transforms the string of bytes back into an R object
  selected_model <- from_byte_string(model_vct_str)
  
  return(selected_model)
  
}


# # To run this code in RStudio you have to define models_df from the file
# # 04-serialize-ml-models-in-power-query.R and then uncomment this one.
# num_rows <- dim(models_df)[1]
# 
# dataset <- models_df %>%
#   filter( model_id == 'model01' ) %>%
#   cbind(
#     data.frame(
#       Age = rep(37, num_rows),
#       Embarked = rep(2, num_rows),
#       Fare = rep(2, num_rows),
#       Parch = rep(2, num_rows),
#       Pclass = rep(3, num_rows),
#       Sex = rep(0, num_rows),
#       SibSp = rep(37, num_rows)
#     )
#   )


# R Visual imports tables using read.csv not setting strings_as_factors = F as parameter.
# This means that chunks are imported as factors and some of them are truncated
# when they have a " " at the end. These chunks will be 9999 long instead of 10000.
# Simply convert to a character and add a space if nchar == 9999 in order to make
# the deserialization work.
dataset <- dataset %>%
  mutate( model_str = as.character(model_str) ) %>%
  mutate( model_str = ifelse(nchar(model_str) == 9999, paste0(model_str, " "), model_str) )



input_tuple_df <- dataset %>% 
  select('Age', 'Embarked', 'Fare', 'Parch', 'Pclass', 'Sex', 'SibSp') %>% 
  distinct()

selected_model <- getModelFromStringSerializedDataframe(dataset)

prediction_label <- predict(selected_model, new_data = input_tuple_df, type = 'class') %>%
  mutate(.pred_class = as.character(.pred_class)) %>% 
  pull()

prediction_score <- predict(selected_model, new_data = input_tuple_df, type = 'prob') %>% 
  pull( paste0('.pred_', prediction_label) )


plot.new()
text(0.5, 0.5,
     labels = paste0('Survived = ', prediction_label, ' (prob = ', round(prediction_score, 3), ')'),
     adj = 0.5, cex = 3.5
)

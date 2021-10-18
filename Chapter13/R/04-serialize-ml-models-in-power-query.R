
# Function that serializes any object to a raw vector (bytes).
# Then it transforms bytes into a string of bytes.
to_string_of_bytes = function(x) {
  paste(as.character(serialize(x, connection = NULL)), collapse = " ")
}

# Function that chops a string 's' into a vector of fixed width character elements.
str_dice <- function(s, width) {
  substring(
    s,
    seq(1, nchar(s), width),
    seq(width, nchar(s) + ifelse(nchar(s) %% width > 0, width-1, 0), width)
  )
}


serializeModelsToStringDataframe <- function(models_lst) {
  
  # Apply to each element of the plots list the function to_string_of_bytes.
  # You'll have a list of serialized plots in string of bytes.
  models_str_lst <- lapply(models_lst, to_string_of_bytes)
  
  # Split each string of bytes in chunks of 10K, in order to avoid the string length limitations in the R Visual
  models_str_vec_lst <- lapply(models_str_lst, str_dice, width = 10000)
  
  
  # Create an empty dataframe
  models_df <- data.frame()
  
  # For each model ID in the list of string of bytes chunks...
  for (model_id in names(models_str_vec_lst)) {
    
    # ...extract the list of chunks
    model_vec = models_str_vec_lst[[model_id]]
    
    # and fill it into a temporary small dataframe
    tmp_df <- data.frame(
      model_id = rep(model_id, length(model_vec)),
      chunk_id = seq(1,length(model_vec),1),
      model_str = model_vec,
      
      stringsAsFactors = FALSE
    )
    
    # Then append the temporary dataframe
    # to the main one (rbind = rows bind)
    models_df <- rbind(models_df, tmp_df)
    
  }
  
  models_ids_df <- data.frame( model_id = names(models_lst) )
  
  return(
    list(
      model_ids_df = models_ids_df,
      models_df = models_df
    )
  )
  
}




project_folder <- r'{C:\<your-path>\Chapter13\}'

# In this case we have only one model. So let's unserialize it as model_01.
# Then let's create a named list containing the models (just one in this case)
model_01 <- readRDS(file.path(project_folder, r'{R\titanic-model.RDS}'))

models_lst <- list('model01' = model_01)


str_models_lst <- serializeModelsToStringDataframe(models_lst)

model_ids_df <- str_models_lst[['model_ids_df']]
models_df <- str_models_lst[['models_df']]


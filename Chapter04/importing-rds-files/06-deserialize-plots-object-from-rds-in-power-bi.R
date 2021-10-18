
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


project_folder <- "D:\\<your-path>\\Chapter04\\importing-rds-files"

# Deserialize the plots list.
plots_lst <- readRDS( file.path(project_folder, "plots_lst.rds") )

# Deserialize the selected countries tibble.
selected_countries_df <- data.frame( country_name = names(plots_lst) )

# Apply to each element of the plots list the function to_string_of_bytes.
# You'll have a list of serialized plots in string of bytes.
plots_str_lst <- lapply(plots_lst, to_string_of_bytes)

# Split each string of bytes in chunks of 10K, in order to avoid the string length limitations in the R Visual
plots_str_vec_lst <- lapply(plots_str_lst, str_dice, width = 10000)


# Create an empty dataframe
plots_df <- data.frame()

# For each country name in the list of string of bytes chunks...
for (country_name in names(plots_str_vec_lst)) {
  
  # ...extract the list of chunks
  plt_vec = plots_str_vec_lst[[country_name]]
  
  # and fill it into a temporary small dataframe
  tmp_df <- data.frame(
    country_name = rep(country_name, length(plt_vec)),
    chunk_id = seq(1,length(plt_vec),1),
    plot_str = plt_vec,
    
    stringsAsFactors = FALSE
  )
  
  # Then append the temporary dataframe
  # to the main one (rbind = rows bind)
  plots_df <- rbind(plots_df, tmp_df)
  
}


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


project_folder <- "D:\\LZavarella\\OneDrive\\MVP\\Packt Book\\Code\\Extending-Power-BI-with-Python-and-R\\Chapter04\\importing-rds-files"

# Deserialize the plots list.
plot_lst <- readRDS( file.path(project_folder, "plot_lst.rds") )

# Deserialize the selected countries tibble.
selected_countries_tbl <- readRDS( file.path(project_folder, "selected_countries_tbl.rds") )

# Apply to each element of the plots list the function to_string_of_bytes.
# You'll have a list of serialized plots in string of bytes.
plot_str_lst <- lapply(plot_lst, to_string_of_bytes)

# Split the string in chunks of 10K, in order to avoid the string length limitations in Power BI import
plot_str_vec_lst <- lapply(plot_str_lst, str_dice, width = 10000)



plots_df <- data.frame()

i <- 1

for (plt_vec in plot_str_vec_lst) {
  
  tmp_df <- data.frame(
    country_id = rep(i, length(plt_vec)),
    chunk_id = seq(1,length(plt_vec),1),
    plot_str = plt_vec,
    
    stringsAsFactors = FALSE
  )
  
  plots_df <- rbind(plots_df, tmp_df)
  
  i <- i + 1  
}

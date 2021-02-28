library(dplyr)
library(ggplot2)

from_byte_string = function(x) {
  xcharvec = strsplit(x, " ")[[1]]
  xhex = as.hexmode(xcharvec)
  xraw = as.raw(xhex)
  unserialize(xraw)
}

# # For debug purposes in RStudio, you have to define plots_df from the file
# # 06-deserialize-plots-object-from-rds-in-power-bi.R. Then you have to
# # select one country filtering by country_name
# dataset <- plots_df %>%
#   filter( country_name == "France" )

# R Visual imports tables using read.csv not setting strings_as_factors = F as parameter.
# This means that chunks are imported as factors and some of them are truncated
# when they have a " " at the end. These chunks will be 9999 long instead of 10000.
# Simply convert to a character and add a space if nchar == 9999 in order to make
# the deserialization work.
dataset <- dataset %>%
  mutate( plot_str = as.character(plot_str) ) %>%
  mutate( plot_str = ifelse(nchar(plot_str) == 9999, paste0(plot_str, " "), plot_str) )

# Sort the contents of the dataframe by increasing chunk_id, to ensure that
# the string chunks are sorted correctly and ready to be deserialized
plot_vct <- dataset %>%
  arrange(country_name, chunk_id) %>%
  pull(plot_str)

# Merge the chunks
plot_vct_str <- paste( plot_vct, collapse = "" )

# Transforms the string of bytes back into an R object
plt <- from_byte_string(plot_vct_str)

# Plot the "plt" variable adding a formatting element for a larger font size
plt + theme(text = element_text(size=20))

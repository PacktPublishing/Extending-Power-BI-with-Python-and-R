library(dplyr)

from_byte_string = function(x) {
  xcharvec = strsplit(x, " ")[[1]]
  xhex = as.hexmode(xcharvec)
  xraw = as.raw(xhex)
  unserialize(xraw)
}

# R Visual imports tables with read.csv but no argument for strings_as_factors = F.
# This means some of the chunks are truncated (ie if they had a " " at the end).
# If you convert to a character and add a space if nchar == 9999 the deserialization works.
# (Thanks to Danny Shah)
dataset <- dataset %>%
  mutate( plot_str = as.character(plot_str) ) %>%
  mutate( plot_str = ifelse(nchar(plot_str) == 9999, paste0(plot_str, " "), plot_str) )

plot_vct <- dataset %>%
  arrange(country_id, chunk_id) %>%
  pull(plot_str)


plot_vct_str <- paste( plot_vct, collapse = "" )

plot <- from_byte_string(plot_vct_str)

plot
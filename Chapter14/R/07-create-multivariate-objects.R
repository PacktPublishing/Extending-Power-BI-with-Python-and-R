
# Load the dataset with proper column data types
folder <- r'{C:\<your-folder>\Chapter14}'
init_path <- file.path(folder, r'{R\00-init-dataset.R}')

if(!exists('foo', mode='function')) source(init_path)


# Get data type of each column
col_types <- sapply(tbl, class)

numeric_cols <- c()
categorical_cols <- c()

for (col_name in names(col_types)) {
  
  if (col_types[col_name] %in% c('integer', 'numeric')) {
    numeric_cols <- c(numeric_cols, col_name)
  }
  
  if (col_types[col_name] %in% c('integer', 'character', 'factor')) {
    categorical_cols <- c(categorical_cols, col_name)
  }
  
}

grp_cols <- c(categorical_cols, '<none>')


# Given a list of vectors, each representing a variable of the dataset,
# the crossing function creates a dataframe made by the cartesian product (cross join)
# of all of them
multivariate_df <- tidyr::crossing(x = numeric_cols, x_transf_type = c('standard','yeo-johnson'),
                                   y = numeric_cols, y_transf_type = c('standard','yeo-johnson'),
                                   cat1 = categorical_cols, cat2 = categorical_cols,
                                   grp = grp_cols)

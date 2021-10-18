library(readr)
library(tidymodels)


project_folder <- r'{C:\<your-path>\Chapter13\}'

titanic_testing <- read_csv(file.path(project_folder, 'titanic-test.csv'))

# Unserialize the model previously trained
rf_final <- readRDS(file.path(project_folder, r'{R\titanic-model.RDS}'))

# Get model predictions for the input dataframe
pred <- predict(rf_final, new_data = titanic_testing, type = 'prob')
pred

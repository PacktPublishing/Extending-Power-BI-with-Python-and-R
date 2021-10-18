
# Install Tidymodels if not already installed
packages <- c('tidymodels', 'ranger')

installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load packages
library(readr)
library(dplyr)
library(tidymodels)

# Load your dataset
project_folder <- r'{C:\Users\<your-path>\Chapter13\}'

# # Uncomment this code if you're not using it in Power BI
# # in order to load the imputed Titanic dataset
# dataset <- read_csv(file.path(project_folder, 'titanic-imputed.csv'))

titanic_tbl <- dataset %>% 
  mutate(Survived = as.factor(Survived))

titanic_split <- initial_split(data = titanic_tbl, strata = "Survived", prop = 0.8)

titanic_train <- training(titanic_split)
titanic_testing <- testing(titanic_split)

train_fold <- titanic_train %>% vfold_cv(5,strata = Survived)


titanic_rec <- recipe(data = titanic_train, formula = Survived ~ .) %>%
  step_dummy(all_nominal(), -all_outcomes(), one_hot = TRUE)

titanic_wf <- workflow() %>%
  add_recipe(titanic_rec)


rf_spec <- rand_forest(
  mtry = tune(),
  trees = 400,
  min_n = tune()) %>%
  set_mode("classification") %>% 
  set_engine(engine = "ranger")


rf_grid <-
  crossing(mtry = 2:4,min_n = seq(10,40,2))



rf_tune <- tune_grid(titanic_wf %>% add_model(rf_spec),
                     resamples = train_fold,
                     grid = rf_grid
)


# # Uncomment this code if you're not using it in Power BI
# rf_tune %>% autoplot()


rf_highest_acc <-
  rf_tune %>% 
  select_best("roc_auc")

rf_wf <- finalize_workflow(
  titanic_wf %>% 
    add_model(rf_spec),
  rf_highest_acc)



rf_fit <- last_fit(rf_wf,titanic_split)

# # Uncomment this code if you're not using it in Power BI
# # to get metric values
# collect_metrics(rf_fit)


rf_final <- rf_fit$.workflow[[1]]

# Save model
saveRDS(rf_final, file.path(project_folder, r'{R\titanic-model.RDS}'))

# Save test dataset
titanic_testing %>% 
  write_csv( file.path(project_folder, 'titanic-test.csv'), eol = '\r\n' )


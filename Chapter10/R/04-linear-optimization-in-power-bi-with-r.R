
library(dplyr)
library(tidyr)
library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)



country_demands <- readRDS(r'{D:\<your-path>\Chapter10\R\country_demands.rds}')
cost_matrix <- readRDS(r'{D:\<your-path>\Chapter10\R\cost_matrix.rds}')
warehouse_supply <- readRDS(r'{D:\<your-path>\Chapter10\R\warehouse_supply.rds}')


n_warehouses <- length(warehouse_supply)
n_countries <- length(country_demands)


model <- MIPModel() %>% 
    add_variable( x[i, j], i = 1:n_warehouses, j = 1:n_countries, type = "integer", lb = 0 ) %>% 
    set_objective( sum_expr(cost_matrix[i, j] * x[i, j], i = 1:n_warehouses, j = 1:n_countries), sense = 'min' ) %>% 
    add_constraint( sum_expr(x[i, j], j = 1:n_countries) <= warehouse_supply[i], i = 1:n_warehouses ) %>% 
    add_constraint( sum_expr(x[i, j], i = 1:n_warehouses) >= country_demands[j], j = 1:n_countries )

result <- model %>% 
    solve_model(with_ROI(solver = 'glpk'))



countries <- colnames(cost_matrix)
warehouses <- rownames(cost_matrix)


decision_var_results <- result$solution[ sort(names(result$solution)) ]

result_df <- data.frame(
    warehouse_name = rep(warehouses, each=n_countries),
    country_name = rep(countries, times=n_warehouses),
    shipped_qty = decision_var_results,
    cost = as.vector(t(cost_matrix)) * decision_var_results
)


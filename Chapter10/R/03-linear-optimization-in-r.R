
library(dplyr)
library(tidyr)
library(readxl)
library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)


warehouse_supply_tbl = read_xlsx(r'{D:\<your-path>\Chapter10\RetailData.xlsx}',
                                 sheet = 'Warehouse Supply')

country_demands_tbl = read_xlsx(r'{D:\<your-path>\Chapter10\RetailData.xlsx}',
                                sheet = 'Country Demand')

cost_matrix_tbl = read_xlsx(r'{D:\<your-path>\Chapter10\RetailData.xlsx}',
                            sheet = 'Shipping Cost')


n_warehouses <- cost_matrix_tbl %>% 
    distinct(warehouse_name) %>% 
    count() %>% 
    pull(n)

n_countries <- cost_matrix_tbl %>% 
    distinct(country_name) %>% 
    count() %>% 
    pull(n)


warehouse_supply <- warehouse_supply_tbl %>% 
    pull(product_qty)

country_demands <- country_demands_tbl %>% 
    pull(product_qty)

# Get the cost matrix from the tibble
# using the pivot_wider function
cost_matrix <- data.matrix(
    cost_matrix_tbl %>% 
        pivot_wider( names_from = country_name, values_from = shipping_cost ) %>% 
        select( -warehouse_name )
)
rownames(cost_matrix) <- warehouse_supply_tbl %>% pull(warehouse_name)
cost_matrix

# Define the model in the ompr language
# It's quite eas to do that following the mathematical model shown in the book
model <- MIPModel() %>% 
    # define the x integer variables, paying attention to define also the lower bound of 0,
    # otherwise the problem is not feasible using the glpk solver
    add_variable( x[i, j], i = 1:n_warehouses, j = 1:n_countries, type = "integer", lb = 0 ) %>% 
    
    # define the objective function, declaring also the "sense" that is the type of problem (minimize)
    set_objective( sum_expr(cost_matrix[i, j] * x[i, j], i = 1:n_warehouses, j = 1:n_countries), sense = 'min' ) %>% 
    
    # add warehouse supply constraints
    add_constraint( sum_expr(x[i, j], j = 1:n_countries) <= warehouse_supply[i], i = 1:n_warehouses ) %>% 
    
    # add customer demand constraints
    add_constraint( sum_expr(x[i, j], i = 1:n_warehouses) >= country_demands[j], j = 1:n_countries )


# Let's check the entered model

# Objective function
as.character( model$objective$expression )

# Problem type
model$objective$sense

# Constraints
model$constraints %>% 
    purrr::map_chr( ~ paste(.x$lhs, .x$sense, .x$rhs) )


#Let's solve the model using the glpk engine
result <- model %>% 
    solve_model(with_ROI(solver = 'glpk'))

# Status of the solution
result$status

# Objective function valued
result$objective_value

# Decision variables valued
decision_var_results <- matrix(result$solution, nrow = n_warehouses, ncol = n_countries, )
rownames(decision_var_results) <- warehouse_supply_tbl %>% pull(warehouse_name)
colnames(decision_var_results) <- country_demands_tbl %>% pull(country_name)

decision_var_results

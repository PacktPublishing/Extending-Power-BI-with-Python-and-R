# %%
import pandas as pd
import numpy as np
import pulp as plp


# %%
# Import data from the Excel file
warehouse_supply_df = pd.read_excel(r'D:\<your-path>\Chapter10\RetailData.xlsx',
                                    sheet_name='Warehouse Supply', engine='openpyxl')
warehouse_supply = warehouse_supply_df['product_qty'].to_numpy()

country_demands_df = pd.read_excel(r'D:\<your-path>\Chapter10\RetailData.xlsx',
                                   sheet_name='Country Demand', engine='openpyxl')
country_demands = country_demands_df['product_qty'].to_numpy()

cost_matrix_df = pd.read_excel(r'D:\<your-path>\Chapter10\RetailData.xlsx',
                               sheet_name='Shipping Cost', engine='openpyxl')

n_warehouses = cost_matrix_df.nunique()['warehouse_name']
n_countries = cost_matrix_df.nunique()['country_name']

cost_matrix = cost_matrix_df['shipping_cost'].to_numpy().reshape(n_warehouses,n_countries)

# %%
# Create a LP problem object
model = plp.LpProblem("supply-demand-minimize-costs-problem", plp.LpMinimize)

# Decision variable names
var_indexes = [str(i)+str(j) for i in range(1, n_warehouses+1) for j in range(1, n_countries+1)]
print("Variable indexes:", var_indexes)

# %%
# Define decision variables
decision_vars = plp.LpVariable.matrix(
    name="x",            # variable name
    indexs=var_indexes,  # variable indexes
    cat="Integer",       # decision variables can only take integer values (default='Continuous')
    lowBound=0 )         # values can't be negative

# Reshape the matrix in order to have the same sizes of the cost matrix
shipping_mtx = np.array(decision_vars).reshape(n_warehouses,n_countries)

print("Shipping quantities matrix:")
print(shipping_mtx)
# %%
# The objective function written in full
objective_func = plp.lpSum(cost_matrix * shipping_mtx)
print(objective_func)

# %%
# Add the objective function to the model object
model += objective_func
print(model)

# %%
# Let's print and add the warehouse supply constraints to the model object
for i in range(n_warehouses):
    print(plp.lpSum(shipping_mtx[i][j] for j in range(n_countries)) <= warehouse_supply[i])
    model += plp.lpSum(shipping_mtx[i][j] for j in range(n_countries)) <= warehouse_supply[i], "Warehouse supply constraints " + str(i)
    
# %%
# Let's print and add the contry demand constraints to the model object
for j in range(n_countries):
    print(plp.lpSum(shipping_mtx[i][j] for i in range(n_warehouses)) >= country_demands[j])
    model += plp.lpSum(shipping_mtx[i][j] for i in range(n_warehouses)) >= country_demands[j] , "Country demand constraints " + str(j)
    
# %%
# Just double-check the final model
print(model)

# %%
# You can also save the model definition into a LP file
model.writeLP('supply-demand-minimize-costs-problem.lp')

# %%
# Solve the linear programming problem
model.solve()

status = plp.LpStatus[model.status]
print(status)  # If the output is 'Optimal' then an optimal solution has been found for the problem.
               # If it is 'Infeasible', the constraints make it impossible to solve the problem.

# %%
# Print the minimum total cost you can spend
print("Total Cost:", model.objective.value())

# %%
# Decision variable values found
decision_var_results = np.empty(shape=(n_warehouses * n_countries))
z = 0
for v in model.variables():
    try:
        decision_var_results[z] = v.value()
        z += 1
    except:
        print("error couldn't find value")

# %%
# Check the product quantities shipped from warehouses to countries
# in a clear way
decision_var_results = decision_var_results.reshape(n_warehouses,n_countries)

col_idxs = ['Italy','France','Germany','Japan','China','USA']
row_idxs = ['Warehouse ITA','Warehouse DEU','Warehouse JPN','Warehouse USA']
dv_res_df = pd.DataFrame(decision_var_results, columns=col_idxs, index=row_idxs)
dv_res_df

# %%
# Get the total shipped quantities for each warehouse
warehouse_shipped_qty = np.zeros(shape=(n_warehouses))
z = 0
for i in range(n_warehouses):
    warehouse_shipped_qty[z] = plp.lpSum(shipping_mtx[i][j].value() for j in range(n_countries)).value()
    z += 1
    
# %%
w_shipped_df = pd.DataFrame(warehouse_shipped_qty, columns=['qty'], index=row_idxs)
w_shipped_df
# %%

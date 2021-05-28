
import pandas as pd
import numpy as np
import pulp as plp
import pickle


warehouse_supply = pickle.load( open(r"D:\<your-path>\Chapter10\Python\warehouse_supply.pkl", "rb") )
country_demands = pickle.load( open(r"D:\<your-path>\Chapter10\Python\country_demands.pkl", "rb") )
cost_matrix = pickle.load( open(r"D:\<your-path>\Chapter10\Python\cost_matrix.pkl", "rb") )

n_warehouses = warehouse_supply.shape[0]
n_countries = country_demands.shape[0]

# Create a LP problem object
model = plp.LpProblem("supply-demand-minimize-costs-problem", plp.LpMinimize)

# Decision variable names
var_indexes = [str(i)+str(j) for i in range(1, n_warehouses+1) for j in range(1, n_countries+1)]

# Define decision variables
decision_vars = plp.LpVariable.matrix(
    name="x",            # variable name
    indexs=var_indexes,  # variable indexes
    cat="Integer",       # decision variables can only take integer values (default='Continuous')
    lowBound=0 )         # values can't be negative

# Reshape the matrix in order to have the same sizes of the cost matrix
shipping_mtx = np.array(decision_vars).reshape(n_warehouses,n_countries)

# The objective function written in full
objective_func = plp.lpSum(cost_matrix * shipping_mtx)

# Add the objective function to the model object
model += objective_func

# Let's print and add the warehouse supply constraints to the model object
for i in range(n_warehouses):
    model += plp.lpSum(shipping_mtx[i][j] for j in range(n_countries)) <= warehouse_supply[i], "Warehouse supply constraints " + str(i)
    
# Let's print and add the contry demand constraints to the model object
for j in range(n_countries):
    model += plp.lpSum(shipping_mtx[i][j] for i in range(n_warehouses)) >= country_demands[j] , "Country demand constraints " + str(j)


model.solve()

status = plp.LpStatus[model.status]

# Decision variable values found
decision_var_results = np.empty(shape=(n_warehouses * n_countries))
z = 0
for v in model.variables():
    try:
        decision_var_results[z] = v.value()
        z += 1
    except:
        print("error couldn't find value")


countries = ['Italy','France','Germany','Japan','China','USA']
warehouses = ['Warehouse ITA','Warehouse DEU','Warehouse JPN','Warehouse USA']

result_df = pd.DataFrame({'warehouse_name': np.repeat(warehouses, n_countries),
                          'country_name': np.tile(countries, n_warehouses),
                          'shipped_qty': decision_var_results,
                          'cost': np.multiply( cost_matrix.reshape(n_warehouses * n_countries), decision_var_results )},
                         columns=['warehouse_name','country_name','shipped_qty','cost'])
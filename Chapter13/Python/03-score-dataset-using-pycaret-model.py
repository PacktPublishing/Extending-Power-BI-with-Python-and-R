# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import pandas as pd
from pycaret.classification import *

# %%
# Uncomment this code if you're not using it in Power BI
# in order to load the imputed test dataset
# dataset = pd.read_csv(r'C:\<your-path>\Chapter13\titanic-test.csv',
#                       index_col=False)
# dataset

# %%
# Unserialize the PyCaret model previously trained
rforest_model = load_model(r'C:\<your-path>\Chapter13\Python\titanic-model')

# %%
# Get model predictions for the input dataframe
predictions = predict_model(rforest_model,data = dataset,verbose=True)
predictions

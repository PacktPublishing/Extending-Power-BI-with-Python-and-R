# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import os
import pandas as pd
import dask.dataframe as dd
from dask.diagnostics import ProgressBar

# %%
# Get the path to the folder containing all the CSV files
# (update it according to your folders structure)
main_path = os.path.join('D:\\', 'data', 'AirOnTime', 'AirOnTimeCSVplot')

# %%
ddf = dd.read_csv(
    os.path.join(main_path, 'airOT*.csv'),                 
    encoding='latin-1',
    usecols =['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY']
)

# %%
mean_dep_delay_ddf = ddf.groupby(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN'])[['DEP_DELAY']].mean().reset_index()

# %%
mean_dep_delay_ddf.visualize(filename='mean_dep_delay_dask.pdf')

# %%
with ProgressBar():
    mean_dep_delay_df = mean_dep_delay_ddf.compute()

# %%
mean_dep_delay_df.head(10)

# %%

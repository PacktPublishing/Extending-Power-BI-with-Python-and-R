# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import pandas as pd
import missingno as msno
from upsetplot import UpSet
import matplotlib.pyplot as plt

# %%
def miss_var_summary(data):
    n_missing = data.isnull().sum()
    percent_missing = data.isnull().sum() * 100 / len(df)
    missing_value_df = pd.DataFrame({'variable': data.columns,
                                     'n_miss' : n_missing,
                                     'pct_miss': percent_missing}).sort_values('n_miss', ascending=False)
    
    return(missing_value_df)

def upsetplot_miss(data):
    
    null_cols_df = data.loc[:, data.isnull().any()]

    missingness = pd.isna(null_cols_df).rename(columns=lambda x: x+'_NA')

    for i, col in enumerate(missingness.columns):
        null_cols_df = null_cols_df.set_index(missingness[col], append=i != 0)

    tuple_false_values = (False, ) * sum(data.isnull().any())
    null_cols_only_miss_df = null_cols_df.loc[null_cols_df.index != tuple_false_values, :]

    upset = UpSet(null_cols_only_miss_df, subset_size='count',
                show_counts = True, sort_by='cardinality')
    
    return(upset)
   



# %%
df = pd.read_csv('http://bit.ly/titanic-dataset-csv')

# %%
msno.matrix(df)
# In case you're not using a Jupyter notebook run also the following:
# plt.show()

# %%
miss_var_summary(df)

# %%
plt = upsetplot_miss(df)
plt.plot()

# In case you're not using a Jupyter notebook run the following instead:
# chart = upsetplot_miss(df)
# chart.plot()
# plt.plot = chart.plot
# plt.show()

# %%

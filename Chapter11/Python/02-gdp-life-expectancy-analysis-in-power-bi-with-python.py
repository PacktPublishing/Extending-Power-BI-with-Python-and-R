# %%
import pandas as pd

corr_df = dataset.corr(method='pearson')

# You need to convert row names into a column
# in order to make it visible in Power BI
corr_df.index.name = 'rowname'
corr_df.reset_index(inplace=True)

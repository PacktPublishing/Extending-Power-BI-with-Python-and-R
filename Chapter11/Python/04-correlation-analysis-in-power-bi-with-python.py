
import pandas as pd
import numpy as np
from dython.nominal import associations


# Calculate the correlations for the 'dataset' dataframe
corr_df = associations(dataset, nom_nom_assoc = 'theil', num_num_assoc = 'pearson', 
                       figsize=(10,10), clustering=True)['corr']

# Transform the resulting correlation dataframe in its 'long' form
dim_corr = corr_df.shape[0]
col_names = corr_df.columns

row = np.array([])
col = np.array([])
corr = np.array([])

for i in range(dim_corr):
    row = np.append(row,np.repeat(col_names[i],dim_corr))
    col = np.append(col,col_names)
    corr = np.append(corr,corr_df.iloc[i])

result_df = pd.DataFrame({'row': row,
                          'col': col,
                          'corr': corr},
                         columns=['row','col','corr'])

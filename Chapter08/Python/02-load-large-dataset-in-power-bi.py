
import os
import pandas as pd
import dask.dataframe as dd


main_path = r'D:\data\AirOnTime\AirOnTimeCSV'

ddf = dd.read_csv(
    os.path.join(main_path, 'airOT*.csv'),                 
    encoding='latin-1',
    usecols =['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY']
)

mean_dep_delay_ddf = ddf.groupby(['YEAR', 'MONTH', 'DAY_OF_MONTH','ORIGIN'])[['DEP_DELAY']].mean().reset_index()

mean_dep_delay_df = mean_dep_delay_ddf.compute()

mean_dep_delay_df.to_csv(r'D:\LZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter08\mean_dep_delay_df.csv', index=False)

import os
import dask.dataframe as dd

main_path = r'C:\Data\AirOnTimeCSVplot'

ddf_1_month = dd.read_csv(
    os.path.join(main_path, 'airOT*.csv'),                 
    encoding='latin-1',
    usecols =['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY']
)

mean_dep_delay_1_month_ddf = ddf_1_month.groupby(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN'])[['DEP_DELAY']].mean().reset_index()

mean_dep_delay_1_month_ddf.visualize(filename='mean_dep_delay_1_month_dask.pdf')

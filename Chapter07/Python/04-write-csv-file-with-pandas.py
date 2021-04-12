import pandas as pd

data = {
    'Col1' : ['A', 'B', 'C,D', 'E"F', 'G\r\nH'],
    'Col2' : [23, 27, 18, 19, 21],
    'Col3' : [3.5, 4.8, 2.1, 2.5, 3.1]
}

data_df = pd.DataFrame(data)

data_df.to_csv(r'D:\<your-path>\Chapter07\Python\example-write.csv',
               index=False)

import pandas as pd

filter = (dataset['isValidDateFromRegex'] == 0)

dataset[filter].to_csv(r'D:\LZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter07\Python\wrong-dates.csv', index=False)

df = dataset[~filter]

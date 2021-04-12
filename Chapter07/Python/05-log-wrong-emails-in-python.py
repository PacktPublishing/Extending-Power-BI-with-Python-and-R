import pandas as pd

filter = (dataset['isEmailValidFromRegex'] == 0)

dataset[filter].to_csv(r'D:\LZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter07\Python\wrong-emails.csv', index=False)

df = dataset[~filter]

import pandas as pd

filter = (dataset['isEmailValidFromRegex'] == 0)

dataset[filter].to_csv(r'D:\<your-path>\Chapter07\Python\wrong-emails.csv', index=False)

df = dataset[~filter]

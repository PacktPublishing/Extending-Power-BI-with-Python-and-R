import pandas as pd

filter_wrong_emails = (dataset['isEmailValidFromRegex'] == 0)
filter_wrong_dates = (dataset['isValidDateFromRegex'] == 0)

dataset[filter_wrong_emails][['UserId', 'Email']].to_excel(r'D:\<your-path>\Chapter07\Python\wrong-data.xlsx', sheet_name='Wrong emails', index = False, engine='openpyxl')

# Append a new worksheet to an existing Excel workbook
with pd.ExcelWriter(r'D:\<your-path>\Chapter07\Python\wrong-data.xlsx', mode='a') as writer: 
     dataset[filter_wrong_dates][['UserId', 'BannedDate']].to_excel(writer, sheet_name='Wrong dates', index = False, engine='openpyxl')

# Keep only rows having valid email and ban date
df = dataset[ ~filter_wrong_emails & ~filter_wrong_dates ]

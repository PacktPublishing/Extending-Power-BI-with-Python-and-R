import pyodbc
import pandas as pd


# Connect to your Azure SQL Database
conn = pyodbc.connect(
    'Driver={ODBC Driver 17 for SQL Server};'
    'Server=lucazav.database.windows.net;'
    'Database=SystemsLogging;'
    'Uid=<your-username>;'
    'Pwd=<your-password>')

# Let's empty the WrongEmails table
cursor = conn.cursor()
cursor.execute('TRUNCATE TABLE WrongEmails')
conn.commit()

filter = (dataset['isEmailValidFromRegex'] == 0)

# Write the wrong emails into the WrongEmails table row by row:
cursor = conn.cursor()

for index, row in dataset[filter][['UserId', 'Email']].iterrows():
    cursor.execute("INSERT INTO WrongEmails (UserId, Email) values(?,?)", row.UserId, row.Email)
conn.commit()
cursor.close()

conn.close()

df = dataset[~filter]

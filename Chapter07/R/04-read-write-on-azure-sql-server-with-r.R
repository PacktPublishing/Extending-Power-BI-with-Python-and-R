library(odbc)
library(DBI)


# Connect to your SQLExpress instance using the Windows Authentication
conn <- dbConnect(
  odbc::odbc(), server = r'{.\SQLExpress}',
  database = 'SystemsLogging', trusted_connection = 'yes',
  driver = '{ODBC Driver 17 for SQL Server}'
)

# You can also connect to it using the SQL Authentication for the 'sa' user if you prefer
# conn <- DBI::dbConnect(
#   odbc::odbc(), server = r'{.\SQLExpress}',
#   database = 'SystemsLogging', uid = 'sa',
#   pwd = '<your_password>',
#   driver = '{ODBC Driver 17 for SQL Server}'
# )

# Read and show some information about databases using a system view
data <- dbGetQuery(conn, "SELECT database_id, name FROM sys.databases")
head(data)

# Disconnect from your SQLExpress instance
dbDisconnect(conn)


# Connect to your Azure SQL Database
conn <- dbConnect(
  odbc::odbc(), server = 'lucazav.database.windows.net',
  database = 'SystemsLogging', uid = '<your-username>',
  pwd = '<your-password>',
  driver = '{ODBC Driver 17 for SQL Server}'
)

# Read and show some information about databases on the Azure SQL server using a system view
data <- dbGetQuery(conn, "SELECT database_id, name FROM sys.databases")
head(data)


# Get data from sample SalesLT.Customers
customers_df <- DBI::dbGetQuery(conn, "SELECT TOP 10 CustomerID AS UserId, EmailAddress AS Email FROM SalesLT.Customer")

# Write customers_df data into the existing WrongEmails table
DBI::dbAppendTable(conn, name = 'WrongEmails', value = customers_df)


# Get the data from the WrongEmails table and show it
df <- DBI::dbGetQuery(conn, "SELECT TOP 10 UserId, Email FROM WrongEmails")
head(df)


# Now let's empty the WrongEmails table
dbSendQuery(conn, "TRUNCATE TABLE WrongEmails")

# Close the connection
dbDisconnect(conn)


import os
import requests
import re
import pandas as pd
import yaml

from bs4 import BeautifulSoup


URL = 'https://docs.microsoft.com/en-us/power-bi/connect-data/service-python-packages-support'
page = requests.get(URL)    # performs an HTTP request to the given URL

soup = BeautifulSoup(page.content, 'html.parser')   # get a parsed HTML object

main_soup = soup.find(id='main') # find the tag having id='main'

#-------------------------------------------------------------------
# Get the actual Python version for Power BI Service Python Visuals
#-------------------------------------------------------------------

# Find the <li> tag that contains 'Python runtime' into its text, then strip it
python_ver_full_str = main_soup.find('li', text=re.compile('Python runtime')).text.strip()

# Extract the version string using regex         
m = re.search('(?<=Python\s)\d{1,3}\.\d{1,3}(\.\d{1,3})?', python_ver_full_str)

python_ver_str = m.group(0) # get the extracted text from the default group (0)


#---------------------------------------------------------------------
# Grab the table containing all the python packages and their version
#---------------------------------------------------------------------

# The goal is to securely target a table cell (the pandas package is sure to be there).
# From that cell, you can then go back to the "parent" objects, until you have referenced the entire table.

# Find all the <td> tags that contains 'pandas' in their text, then get the first one of them
pandas_cell_soup = main_soup.findAll('td', text=re.compile('pandas'))[0]

# Now start from that cell and go back to the parent table
packages_table_soup = pandas_cell_soup.parent.parent.parent

# Get all the row-elements of the table, including the headers (the body)
packages_body_soup = packages_table_soup.find_all('tr')

# Extract the first row-element from the body: it's the header
packages_header_soup = packages_body_soup[0]

# Extract all the row-elements from the body except the first one: we have the table rows
packages_rows_soup = packages_body_soup[1:]

# Let's parse the header in order to collect the table's column names in a list
column_names = []
for item in packages_header_soup.find_all('th'):# loop through all th elements
    item = (item.text).rstrip('\n')             # convert the th elements to text and strip "\n"
    column_names.append(item)                   # append the clean column name to column_names
    
# Let's parse all the row-elements in order to collect the table's rows in a list
packages_rows = []
for row_idx in range(len(packages_rows_soup)):  # loop all the row-elements using their index
    row = []                                    # this list will hold data cells for one row
    for row_item_soup in packages_rows_soup[row_idx].find_all('td'): # loop through all data cells of a fixed row
        
        # Remove \xa0 (non-breaking spaces), \n (new lines), \\s any whitespace char into the data cell
        # (packages don't have spaces in their name) and comma (thousands separator) from row_item.text
        # (the stripped data cell) using regex
        cell_text = re.sub('(\xa0)|(\n)|,|\\s', '', row_item_soup.text)
        row.append(cell_text) # append cell_text to row list
        
    packages_rows.append(row) # append one row to packages_rows

# Use the parsed lists of rows and column names to create a pandas dataframe
df = pd.DataFrame(data=packages_rows,columns=column_names)


#----------------------------------------------------
# Write an environment YAML file using the dataframe
#----------------------------------------------------
packages_df = df.drop('Link', axis=1)

packages_version_lst = packages_df.agg('=='.join, axis=1).values.tolist()

# Now let's write a YAML file using the scraped info about packages
packages_dict = [
    {'name': 'pbi_visuals_env'},
    {
        'dependencies': [
            'python==%s' % python_ver_str,
            'pip',
            {'pip': packages_version_lst}
        ]
    }
]

print( yaml.dump(packages_dict, default_flow_style=False) )

destination_path = r'.'

## In case you want to create a subfolder
#os.makedirs(destination_path, exist_ok=True)

yaml_file_name = 'visuals_environment.yaml'

with open(os.path.join(destination_path, yaml_file_name), 'w') as file:
    documents = yaml.dump(packages_dict, file)



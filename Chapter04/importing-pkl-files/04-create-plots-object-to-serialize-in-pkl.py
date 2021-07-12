import os
import pandas as pd
import pickle
import matplotlib.pyplot as plt

# Load the data into a dataframe
project_folder = "C:\\Users\\LucaZavarella\\OneDrive\\MVP\\PacktBook\\Code\\Extending-Power-BI-with-Python-and-R\\Chapter04\\importing-pkl-files"
population_df = pd.read_csv(os.path.join(project_folder, "population.csv"))

# Define a list of selected countries
selected_countries = ["Italy", "Sweden", "France", "Germany"]

# Let's create a dataframe having only rows for selected countries.
# The isin() method helps in selecting rows with having a particular (or multiple) value(s) in a particular column
selected_population_df = population_df.loc[ population_df['country'].isin(selected_countries) ]

# Define an empty dictionary
nested_population_dict = {}

# For each country...
for c in selected_countries:

    # ... organize its 'year' and 'population' data in a dataframe and
    # insert it in the dictionary in correspondence of the country name
    nested_population_dict[c] = selected_population_df.loc[ population_df['country'] == c ].filter(['year', 'population']).reset_index(drop=True)

# Let's try to plot the time series for Sweden
selected_country = "Sweden"
x = nested_population_dict[selected_country].year
y = nested_population_dict[selected_country].population

# Create a figure object
fig_handle = plt.figure()
# Plot a simple line for each (x,y) point
plt.plot(x, y)
# Add a title to the figure
plt.title("Global population of " + selected_country)

# Show the figure
fig_handle.show()


# Define another empty dictionary that will contain the pictures for each country
nested_population_plots_dict = {}

# For each country...
for c in selected_countries:
    
    # ...get its time series dataframe using the previous dictionary
    tmp_df = nested_population_dict[c]
    
    # Prepare the plot
    x = tmp_df.year
    y = tmp_df.population
    
    fig_handle = plt.figure()
    plt.plot(x, y)
    plt.title("Global population of " + c)

    # Add the plot into the new dictionary, coupled to its country name
    nested_population_plots_dict[c] = fig_handle

# Picle the entire plots dictionary and write it to disk
pickle.dump( nested_population_plots_dict, open(os.path.join(project_folder, "nested_population_plots_dict.pkl"), "wb") )

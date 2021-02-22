
import pandas as pd
import pickle

# Load the 'population.csv' file from the current selected folder
population_df = pd.read_csv("population.csv")

# Get all the distinct countries in a NumPy array
# from the population dataframe. If you are confused
# about the differences between arrays and lists,
# take a look here: https://learnpython.com/blog/python-array-vs-list/
countries = population_df.country.unique()

# Define an empty dictionary
nested_population_dict = {}

# For each unique country...
for c in countries:

    # Get the boolean indexes for rows having the current country c of the loop,
    # get a dataframe having those rows (using loc),
    # keep only the 'year' and 'population' columns (using filter),
    # reset the index of the selected rows so it'll start from 0, and
    # at the end associate the dataframe obtained from the selection to the country c, and insert this couple in the dictionary
    nested_population_dict[c] = population_df.loc[ population_df['country'] == c ].filter(['year', 'population']).reset_index(drop=True)

# Picle the entire dictionary and write it to disk
pickle.dump( nested_population_dict, open("nested_population_dict.pkl", "wb") )

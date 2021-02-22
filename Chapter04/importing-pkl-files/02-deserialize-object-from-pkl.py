import pandas as pd
import pickle

# Deserialize your dictionary using the load function of pickle
deserialized_dict = pickle.load( open("nested_population_dict.pkl", "rb") )

# Get the dataframe of data related to Sweden
sweden_population_df = deserialized_dict['Sweden']

# Show the data
print(sweden_population_df)

import pandas as pd
import pickle

deserialized_dict = pickle.load( open("nested_population_dict.pkl", "rb") )

sweden_population_df = deserialized_dict['Sweden']

print(sweden_population_df)

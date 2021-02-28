import pandas as pd
import pickle
import os


project_folder = "D:\\LZavarella\\OneDrive\\MVP\\PacktBook\\Code\\Extending-Power-BI-with-Python-and-R\\Chapter04\\importing-pkl-files"

deserialized_dict = pickle.load( open(os.path.join(project_folder, "nested_population_dict.pkl"), "rb") )

sweden_population_df = deserialized_dict['Sweden']

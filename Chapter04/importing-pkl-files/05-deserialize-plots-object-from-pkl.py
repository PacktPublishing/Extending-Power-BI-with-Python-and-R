import pandas as pd
import pickle
import os


project_folder = "D:\\<your>\\<project>\\<folder>"

deserialized_plots_dict = pickle.load( open(os.path.join(project_folder, "nested_population_plots_dict.pkl"), "rb") )

selected_country = "Italy"

fig_handle = deserialized_plots_dict[selected_country]
fig_handle.show()

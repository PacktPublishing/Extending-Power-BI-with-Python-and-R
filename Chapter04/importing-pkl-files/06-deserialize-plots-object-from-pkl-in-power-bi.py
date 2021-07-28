import pickle
import re
import os
import pandas as pd


def serialize(obj):
    return obj.encode('latin1')

def unserialize(obj):
    return obj.decode('latin1')

def toPickle(obj):
    return pickle.dumps(obj, 0)

def toUnpickle(obj):
    return pickle.loads(obj)

def toCut(obj, width):
    return re.findall('.{1,%s}' % width, obj, flags=re.S)

def toUncut(obj):
    return "".join(obj)



project_folder = "D:\\<your-path>\\Chapter04\\importing-pkl-files"

plots_dict = pickle.load(open(os.path.join(project_folder, "nested_population_plots_dict.pkl"),"rb"))

pickled_plots_dict = {}
for country in plots_dict:
    # each figure serialized to a Bytearray
    pickled_plots_dict[country] = toPickle(plots_dict[country])

pickled_plots_int_array_dict = {}
for country in pickled_plots_dict:
    # each Bytearray transformed into a dictionary of int arrays
    pickled_plots_int_array_dict[country] = [x for x in pickled_plots_dict[country]]

pickled_plots_int_str_dict = {}
for country in pickled_plots_int_array_dict:
    # each int array transformed into a string representation of int array (space as separator of integers)
    pickled_plots_int_str_dict[country] = " ".join( [str(a) for a in pickled_plots_int_array_dict[country]] )

pickled_plots_int_str_chopped_dict = {}
for country in pickled_plots_int_str_dict:
    # each string of integers transformed into a list of string chunks having width 32000 (Python Visual limitation: 32766)
    pickled_plots_int_str_chopped_dict[country] = toCut(pickled_plots_int_str_dict[country], width=32000)


plots_df_lst = []

# For each country name taken from the pickled_plots_int_str_chopped_dict...
for country in pickled_plots_int_str_chopped_dict:

    # ...get the chops list for the current country
    chops_lst = pickled_plots_int_str_chopped_dict[country]
    # get the number of chunks contained into the list
    num_chops = len(chops_lst)

    # create a temporary dataframe containing the country name, an integer index
    # counting the chunks and the chops list strings content
    tmp_data = {
        'country_name': [country] * num_chops,
        'chunk_id': list(range(1, num_chops+1)),
        'plot_str': chops_lst
    }

    tmp_df = pd.DataFrame(tmp_data, columns = ['country_name','chunk_id','plot_str'])

    # append the temporary dataframe to the plots_df_lst list of dataframes
    plots_df_lst.append(tmp_df)

# Merge all the plots_df_lst dataframes into the plots_df dataframe
plots_df = pd.concat(plots_df_lst, ignore_index=True)

# Create also the country names dataframe
selected_countries_df = pd.DataFrame( pickled_plots_int_str_chopped_dict.keys(), columns = ['country_name'])


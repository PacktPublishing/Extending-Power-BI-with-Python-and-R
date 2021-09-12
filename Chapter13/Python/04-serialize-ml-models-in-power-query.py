import pickle
import re
import os
import pandas as pd
from pycaret.classification import *


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


def serializeModelsToStringDataframe(models_dict):
    pickled_models_dict = {}
    for model_id in models_dict:
        # each model serialized to a Bytearray
        pickled_models_dict[model_id] = toPickle(models_dict[model_id])

    pickled_models_int_array_dict = {}
    for model_id in pickled_models_dict:
        # each Bytearray transformed into a dictionary of int arrays
        pickled_models_int_array_dict[model_id] = [x for x in pickled_models_dict[model_id]]


    pickled_models_int_str_dict = {}
    for model_id in pickled_models_int_array_dict:
        # each int array transformed into a string representation of int array (space as separator of integers)
        pickled_models_int_str_dict[model_id] = " ".join( [str(a) for a in pickled_models_int_array_dict[model_id]] )


    pickled_models_int_str_chopped_dict = {}
    for model_id in pickled_models_int_str_dict:
        # each string of integers transformed into a list of string chunks having width 32000 (Python Visual limitation: 32766)
        pickled_models_int_str_chopped_dict[model_id] = toCut(pickled_models_int_str_dict[model_id], width=32000)


    models_df_lst = []
    # For each model_id taken from the pickled_plots_int_str_chopped_dict...
    for model_id in pickled_models_int_str_chopped_dict:

        # ...get the chops list for the current model_id
        chops_lst = pickled_models_int_str_chopped_dict[model_id]
        # get the number of chunks contained into the list
        num_chops = len(chops_lst)

        # create a temporary dataframe containing the model ID, an integer index
        # counting the chunks and the chops list strings content
        tmp_data = {
            'model_id': [model_id] * num_chops,
            'chunk_id': list(range(1, num_chops+1)),
            'model_str': chops_lst
        }

        tmp_df = pd.DataFrame(tmp_data, columns = ['model_id','chunk_id','model_str'])

        # append the temporary dataframe to the models_df_lst list of dataframes
        models_df_lst.append(tmp_df)


    # Merge all the models_df_lst dataframes into the models_df dataframe
    models_df = pd.concat(models_df_lst, ignore_index=True)

    # Create also the model IDs dataframe
    model_ids_df = pd.DataFrame( pickled_models_int_str_chopped_dict.keys(), columns = ['model_id'])

    return model_ids_df, models_df


project_folder = r'C:\<your-path>\Chapter13\Python'

# In this case we have only one model. So let's unserialize it as model_01.
# Then let's create a dictionary containing the models (just one in this case)
# Remeber you mustn't add the extension .pkl
model_01 = load_model(os.path.join(project_folder, "titanic-model"))

models_dict = {}
models_dict['model01'] = model_01


# Get the dataframe of model IDs and the dataframe of serialized models
model_ids_df, models_df = serializeModelsToStringDataframe(models_dict)


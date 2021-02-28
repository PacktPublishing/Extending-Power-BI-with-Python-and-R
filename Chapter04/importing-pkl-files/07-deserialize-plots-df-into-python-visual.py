
# Python Visual truncates the dataframe values to 32766 characters max

import pandas as pd
import pickle
import matplotlib.pyplot as plt


def serialize(obj):
    return obj.encode('latin1')

def unserialize(obj):
    return obj.decode('latin1')


def toUnpickle(obj):
    return pickle.loads(obj)


def toUncut(obj):
    return "".join(obj)


dataset = dataset.sort_values(['chunk_id'], ascending=[True])
dataset = dataset.reset_index(drop=True)

dataset_fixed = dataset
dataset_fixed.loc[:,'plot_str'] = dataset['plot_str'].apply( lambda x: x + ' ' if len(x) == 31999 else x)

str_merged = toUncut(dataset_fixed['plot_str'])

str_int_list = list(map(int, str_merged.split()))

str_pickled_byte_string = bytearray(str_int_list)

str_unpickled = toUnpickle(str_pickled_byte_string)

mng = plt.get_current_fig_manager()
mng.figure = str_unpickled

plt.show()

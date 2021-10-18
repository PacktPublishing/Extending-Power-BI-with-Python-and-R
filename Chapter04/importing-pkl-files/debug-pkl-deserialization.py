# Python Visual truncates the dataframe values to 32766 characters max

import pandas as pd
import pickle

project_folder = "D:\\<your-path>\\Chapter04\\importing-pkl-files"

dataset_debug = pd.read_csv( open(os.path.join(project_folder, "input_df_python_visual.csv"), "rb") )

def serialize(obj):
    return obj.encode('latin1')

def unserialize(obj):
    return obj.decode('latin1')


def toUnpickle(obj):
    return pickle.loads(obj)


def toUncut(obj):
    return "".join(obj)



dataset_debug = dataset_debug.sort_values(['chunk_id'], ascending=[True])
dataset_debug = dataset_debug.reset_index(drop=True)

for i in range(0, len(dataset['plot_str'])):
    dataset_debug['plot_str'][i] == dataset['plot_str'][i]

for i in range(0, len(dataset['plot_str'])):
    if len(dataset_debug['plot_str'][i]) != len(dataset['plot_str'][i]):
        arrow = '  <--'
    else:
        arrow = ''

    print( 'Len debug (%s) = %s  |  Len orig (%s) = %s %s' % (i, len(dataset_debug['plot_str'][i]), i, len(dataset['plot_str'][i]), arrow) )

# # Get strings to compare in Notepad++
# dataset['plot_str'][7]
# dataset_debug['plot_str'][7]

# dataset['plot_str'][10]
# dataset_debug['plot_str'][10]

dataset_debug_fixed = dataset_debug
dataset_debug_fixed.loc[:,'plot_str'] = dataset_debug['plot_str'].apply( lambda x: x + ' ' if len(x) == 31999 else x)

for i in range(0, len(dataset['plot_str'])):
    if len(dataset_debug_fixed['plot_str'][i]) != len(dataset['plot_str'][i]):
        arrow = '  <--'
    else:
        arrow = ''

    print( 'Len debug (%s) = %s  |  Len orig (%s) = %s %s' % (i, len(dataset_debug_fixed['plot_str'][i]), i, len(dataset['plot_str'][i]), arrow) )



str_merged_debug_fixed = toUncut(dataset_debug_fixed['plot_str'])

str_int_list_debug_fixed = list(map(int, str_merged_debug_fixed.split()))

str_pickled_byte_string_debug_fixed = bytearray(str_int_list_debug_fixed)

str_unpickled_debug_fixed = toUnpickle(str_pickled_byte_string_debug_fixed)

str_unpickled_debug_fixed.show()

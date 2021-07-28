
# %%
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from pycaret.classification import *

# %%
# Uncomment this code if you're not using it in Power BI
# in order to load the imputed Titanic dataset
# dataset = pd.read_csv(r'C:\<your-path>\Chapter13\titanic-imputed.csv')
# dataset

# %%
# Let's split the dataframe in a small part to be kept for test purpose and
# a large part for training.
X = dataset.drop('Survived',axis=1)
y = dataset[['Survived']]

X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.05)

# %%
# Merge the feature training dataframe and target training column in a unique training dataframe 
df_training = pd.concat([X_train, y_train], axis=1, ignore_index=True).reset_index(drop=True, inplace=False)
# Create an array concatenating column names of features and target variable
col_names = np.concatenate((X.columns, y.columns),axis=0)
# Assign column names to the new dataframe
df_training = df_training.set_axis(col_names,axis=1)

# %%
# Force the float values of Pclass to integer, as Power BI imports it as an int column
df_training['Pclass'] = df_training['Pclass'].astype('int')

# %%
# Setup the PyCaret AutoML experiment properly
exp_clf = setup(data = df_training, target = 'Survived', session_id=5614,
                categorical_features=['Sex','Embarked'],
                ordinal_features={'Pclass' : [1,2,3]},
                n_jobs=1, # remove parallelism in order to work in Power BI
                silent=True,
                verbose=False)

# %%
# Get the model that performs better in the cross-validation phase.
# Use verbose=True to get all the metrics as output in VS Code.
best_model = compare_models(verbose=True)

# %%
# Save the model in a pkl file for future reuse
save_model(best_model, r'C:\<your-path>\Chapter13\Python\titanic-model')

# %%
# Merge the feature test dataframe and target test column in a unique test dataframe
# and save it in a CSV file for future reuse
df_test = pd.concat([X_test, y_test], axis=1, ignore_index=True).reset_index(drop=True, inplace=False)
df_test = df_training.set_axis(col_names,axis=1)
# %%
df_test.to_csv(r'C:\<your-path>\Chapter13\titanic-test.csv',
               index=False)

# %%
# Get model predictions for the test dataframe
predictions = predict_model(best_model,data = df_test,verbose=False)
predictions

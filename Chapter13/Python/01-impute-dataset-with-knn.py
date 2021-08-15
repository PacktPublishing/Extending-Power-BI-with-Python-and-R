# %%
import numpy as np
import pandas as pd

# %%
from sklearn.impute import KNNImputer
from sklearn.preprocessing import OrdinalEncoder
from sklearn.compose import ColumnTransformer

# %%
# Uncomment this if not using in Power BI
# dataset = pd.read_csv('http://bit.ly/titanic-dataset-csv')
# dataset

# %%
# Let's drop the 'Cabin' column as it contains too much NaN
# Let's drop the columns PassengerId, Name and Ticket as they have too much distinct values
# and also drop rows where Embarked is null
df_clean = dataset.drop(['Cabin','PassengerId','Name','Ticket'], axis=1)[dataset['Embarked'].notna()] 

# %%
# Get the column indexes of categorical features (Sex and Embarked)
categorical_idx = df_clean.select_dtypes(include=['object', 'bool']).columns
# Let's define the transformer for categorical features.
# A transformer is a three-element tuple defined by the name of the transformer, the transform to apply,
# and the column indices to apply it to. In this case we apply the ordinal encoding to each categorical column
t = [('cat', OrdinalEncoder(), categorical_idx)]
col_transform = ColumnTransformer(transformers=t)

# Get the only two transformed columns
X = col_transform.fit_transform(df_clean)

# Replace the Sex and Embarked columns of a new dataframe with the transformed columns
df_transf = df_clean.copy()
df_transf[categorical_idx.tolist()] = X

# %%
# Let's impute Age using knn algorithm
imputer = KNNImputer(n_neighbors=5, weights='uniform', metric='nan_euclidean', 
                     missing_values=np.nan, add_indicator=False)

# Fit on cleaned dataframe
imputer.fit(df_transf)
# Transform the dataframe according to the imputer and get the imputed matrix
matrix_imputed = imputer.transform(df_transf)

# %%
# Let's transform back the matrix into a dataframe using the same
# column names of the cleaned dataframe
df_imputed = pd.DataFrame(matrix_imputed, columns=df_clean.columns)
df_imputed['Survived'] = df_imputed['Survived'].astype('int')

# %%
# Uncomment this if not using the code in Power BI, as the imputed dataset
# will be used in the training code
df_imputed.to_csv(r'C:\<your-path>\Chapter13\titanic-imputed.csv',
                  index=False)

# %%

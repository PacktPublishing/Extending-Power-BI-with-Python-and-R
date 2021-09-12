# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import pandas as pd
import numpy as np
from sklearn.preprocessing import PowerTransformer
from sklearn.covariance import MinCovDet
from scipy.stats import chi2

import seaborn as sb
import matplotlib.pyplot as plt



# %%
def add_is_outlier_IQR(data, col_name):
    col_values = data[col_name]
    
    Q1=col_values.quantile(0.25)
    Q3=col_values.quantile(0.75)
    IQR=Q3-Q1
    
    outliers_col_name = f'is_{col_name.replace(" ", "_")}_outlier'
    data[outliers_col_name] = ((col_values < (Q1 - 1.5 * IQR)) | (col_values > (Q3 + 1.5 * IQR)))
    
    return data


def boxPlot(data, varx, vary, title, xlab, ylab, hue = None):
    hplot = sb.boxplot(varx, vary, hue=hue, data=data)
    plt.title(title, fontsize=18)
    plt.xlabel(xlab, fontsize=16)
    plt.ylabel(ylab, fontsize=16)
    
    return hplot


def yeo_johnson_transf(data):
    pt = PowerTransformer(method='yeo-johnson', standardize=True)
    pt.fit(data)

    lambdas = pt.lambdas_
    df_yeojohnson = pd.DataFrame( pt.transform(df[numeric_col_names]), columns=numeric_col_names )
    
    return df_yeojohnson, lambdas


# %%
# Load red wine data
df = pd.read_csv('https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv',
                 sep=';')

# Get numeric column names but the quality
numeric_col_names = df.drop('quality', axis=1).columns.values

df

# %%
sb.set_theme(style="whitegrid")

# Let's plot sulphates boxplot in order to see if
# there are univariate outliers
boxPlot(df, varx='sulphates', vary=None,
        title='Sulphates distribution',
        xlab='sulphates', ylab=None)

# %%
# As you see there are outliers, let's add a boolean 
# column to the dataframeindicating which row
# has a sulphate outlier
add_is_outlier_IQR(df, 'sulphates')

# Let's plot the boxplot removing the initial outliers
df_no_outliers = df.loc[~df['is_sulphates_outlier']]

boxPlot(df_no_outliers, varx='sulphates', vary=None,
        title='Sulphates distribution without outliers',
        xlab='sulphates', ylab=None)

# %%
# Let's now plot boxplots for each quality vote,
# removing the initial outliers
boxPlot(df_no_outliers, varx='quality', vary='sulphates',
        title='Sulphates distribution without outliers',
        xlab='sulphates', ylab=None)

# %%
# Let's now plot an histogram for all the variables
# using the original dataset
df.drop('quality', axis=1).hist(figsize=(10,10))
plt.tight_layout()
plt.show()

# %%
# Let's apply Yeo-Johnson transformations
# in order to remove skewness
df_transf, lambda_arr = yeo_johnson_transf(df[numeric_col_names])

# Let's plot an histogram for all the transformed variables
# in order to check if skewness is decreased 
df_transf.hist(figsize=(10,10))
plt.tight_layout()
plt.show()

# %%
# # WARNING: The following plots take some minutes to get plotted.
# #
# # If you want to check also the density plots of each variable and
# # the scatter plots between all of them two by two, grouped by quality,
# # you can use the pairplot. This one is using the original dataframe...
# sb.pairplot(df, hue='quality', diag_kind = 'kde',
#             plot_kws = {'alpha': 0.6, 's': 80, 'edgecolor': 'k'})

# # %%
# # ... and this one is generated using the transformed dataframe.
# df_transf_qual = df_transf.copy()
# df_transf_qual['quality'] = df['quality']

# sb.pairplot(df_transf_qual, hue='quality', diag_kind = 'kde',
#             plot_kws = {'alpha': 0.6, 's': 80, 'edgecolor': 'k'})

# %%
# Let's compute the squared Mahalanobis distances using
# the Minimum Covariance Determinant to calculate a
# robust covariance matrix
robust_cov = MinCovDet(support_fraction=0.7).fit(df_transf)
center = robust_cov.location_

D = robust_cov.mahalanobis(df_transf - center)
D

# %%
# The squared Mahalanobis distance (D) follows a Chi-Square distribution
# (https://markusthill.github.io/mahalanbis-chi-squared/#the-squared-mahalanobis-distance-follows-a-chi-square-distribution-more-formal-derivation)
#
# Given a cutoff value associated with the statistical significance
# with which we want to determine outliers, we obtain the corresponding
# threshold value above which to consider an observation an outlier
cutoff = 0.98
degrees_of_freedom = df_transf.shape[1]  # given by the number of variables (columns)
cut = chi2.ppf(cutoff, degrees_of_freedom) # threshold value

# Squared Mahalanobis distance values of outliers
D[D > cut]

# %%
# Calculate the probability that the distance D[5]
# is an outlier
chi2.cdf(D[5], degrees_of_freedom)

# %%
# Calulate if the observation is an outlier given the cutoff
is_outlier_arr = (D > cut)

# Calculate the probability that an observation is an outlier not by chance
outliers_stat_proba = np.zeros(len(is_outlier_arr))

for i in range(len(is_outlier_arr)):
    outliers_stat_proba[i] = chi2.cdf(D[i], degrees_of_freedom)

# How many outliers with statistical significance greater than the cutoff
len(outliers_stat_proba[outliers_stat_proba > cutoff])


# %%
# Adding outliers info to the dataframe according to
# the squared Mahalanobis distance
df['is_mahalanobis_outlier'] = is_outlier_arr
df['mahalanobis_outlier_proba'] = outliers_stat_proba

df[df['is_mahalanobis_outlier']]


# %%

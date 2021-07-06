import pandas as pd
import numpy as np
from sklearn.preprocessing import PowerTransformer
from sklearn.covariance import MinCovDet
from scipy.stats import chi2


def add_is_outlier_IQR(data, col_name):
    col_values = data[col_name]
    
    Q1=col_values.quantile(0.25)
    Q3=col_values.quantile(0.75)
    IQR=Q3-Q1
    
    outliers_col_name = f'is_{col_name.replace(" ", "_")}_outlier'
    data[outliers_col_name] = ((col_values < (Q1 - 1.5 * IQR)) | (col_values > (Q3 + 1.5 * IQR)))
    
    return data


def yeo_johnson_transf(data):
    pt = PowerTransformer(method='yeo-johnson', standardize=True)
    pt.fit(data)

    lambdas = pt.lambdas_
    df_yeojohnson = pd.DataFrame( pt.transform(dataset[numeric_col_names]), columns=numeric_col_names )
    
    return df_yeojohnson, lambdas



# Get numeric column names but the quality
numeric_col_names = dataset.drop('quality', axis=1).columns.values


# As you see there are outliers, let's add a boolean 
# column to the dataframeindicating which row
# has a sulphate outlier
add_is_outlier_IQR(dataset, 'sulphates')

# Let's plot the boxplot removing the initial outliers
df_no_outliers = dataset.loc[~dataset['is_sulphates_outlier']]


# Let's apply Yeo-Johnson transformations
# in order to remove skewness
df_transf, lambda_arr = yeo_johnson_transf(dataset[numeric_col_names])


# Let's compute the squared Mahalanobis distances using
# the Minimum Covariance Determinant to calculate a
# robust covariance matrix
robust_cov = MinCovDet(support_fraction=0.7).fit(df_transf)
center = robust_cov.location_

D = robust_cov.mahalanobis(df_transf - center)


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


# Calculate the probability that the distance D[5]
# is an outlier
chi2.cdf(D[5], degrees_of_freedom)

# Calulate if the observation is an outlier given the cutoff
is_outlier_arr = (D > cut)

# Calculate the probability that an observation is an outlier not by chance
outliers_stat_proba = np.zeros(len(is_outlier_arr))

for i in range(len(is_outlier_arr)):
    outliers_stat_proba[i] = chi2.cdf(D[i], degrees_of_freedom)


# Adding outliers info to the dataframe according to
# the squared Mahalanobis distance
dataset['is_mahalanobis_outlier'] = is_outlier_arr
dataset['mahalanobis_outlier_proba'] = outliers_stat_proba


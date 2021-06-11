# %%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sb
from statsmodels.graphics.mosaicplot import mosaic
from dython.nominal import cramers_v
from dython.nominal import theils_u
from dython.nominal import correlation_ratio
from dython.nominal import associations

# %%
def violinPlot(data, varx, vary, title, xlab, ylab, hue = None):
    hplot = sb.violinplot(varx, vary, hue=hue, split=(hue is not None), data=data)
    plt.title(title, fontsize=18)
    plt.xlabel(xlab, fontsize=16)
    plt.ylabel(ylab, fontsize=16)
    
    return hplot


# %%
# Load the Titanic disaster dataset
dataset_url = 'http://bit.ly/titanic-data-csv'

df = pd.read_csv(dataset_url)
df.head()

# %%
# Transform categorical variables in string columns
categ_cols = ['Survived', 'Pclass']
df[categ_cols] = df[categ_cols].astype(str) 
df

# %%
# Let's calculate the Cramér's V coefficient for Survived and Pclass
cramers_v(df['Survived'], df['Pclass'], bias_correction=False)

# %%
# Let's verify that Cramér's V is a symmetric function
cramers_v(df['Survived'], df['Pclass']) == cramers_v(df['Pclass'], df['Survived'])

# %%
# You can also draw a mosaic plot for these variables
mosaic(data=df, index=['Survived', 'Pclass'], statistic=True, axes_label=True, gap=[0.01,0.02])

# %%
# Take advantage of the asymmetry of Theil's U calculating it for the same variables.
# This is U(Survived|Pcalss) that is "U for Survived given Pclass"
theils_u(df['Survived'], df['Pclass'])

# %%
# Just check that the opposite direction gives you a different result
theils_u(df['Pclass'], df['Survived'])

# %%
# Let's draw a violin plot of Age and Pclass
violinPlot(data=df, varx='Pclass', vary='Age',
           title='Passenger age VS Passenger class',
           xlab='Pclass', ylab='Age')

# %%
# You can also show the distribution of a third dimension (in this case Survived)
# coloring half violin plot
violinPlot(data=df, varx='Pclass', vary='Age', hue='Survived',
           title='Passenger age VS Passenger class',
           xlab='Pclass', ylab='Age')

# %%
# Let's calculate the correlation ratio between the categorical variable Pclass and
# the numeric one Age
correlation_ratio(categories=df['Pclass'], measurements=df['Age'])

# %%
# Let's show how the correlation ratio will change changing the dispersion of observations for each category
t1 = pd.DataFrame(
    {
        'topic': ['Algebra','Algebra','Algebra','Algebra','Algebra','Geometry','Geometry','Geometry','Geometry','Statistics','Statistics','Statistics','Statistics','Statistics','Statistics'],
        'score': [45,70,29,15,21,40,20,30,42,65,95,80,70,85,73]
    }
)

violinPlot(data=t1, varx='topic', vary='score',
           title='', xlab='',ylab='')

# %%
t2 = pd.DataFrame(
    {
        'topic': ['Algebra','Algebra','Algebra','Algebra','Algebra','Geometry','Geometry','Geometry','Geometry','Statistics','Statistics','Statistics','Statistics','Statistics','Statistics'],
        'score': [36,36,36,36,36,33,33,33,33,78,78,78,78,78,78]
    }
)

violinPlot(data=t2, varx='topic', vary='score',
           title='', xlab='',ylab='')

# %%
# Calculate correlation coefficients for a Pandas dataframe regardless column data types
ass = associations(df, theil_u=False, figsize=(10,10), clustering=True)

# %%
ass['corr']

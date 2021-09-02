# %%
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sb


# %%
def distPlot(data, var, title, xlab, ylab, bins=100):
    hplot = sb.displot(data[var], kde=False, bins=bins)
    plt.title(title, fontsize=18)
    plt.xlabel(xlab, fontsize=16)
    plt.ylabel(ylab, fontsize=16)
    
    return hplot

def scatterPlot(data, varx, vary, title, xlab, ylab):
    hplot = sb.scatterplot(varx, vary, data=data)
    plt.title(title, fontsize=18)
    plt.xlabel(xlab, fontsize=16)
    plt.ylabel(ylab, fontsize=16)
    
    return hplot



# %%
dataset_url = 'http://bit.ly/gdp-life-expect-data'

df = pd.read_csv(dataset_url)
df.head()

# %%
distPlot(data=df, var='lifeExp', title='Life Expectancy',
         xlab='Life Expectancy (years)', ylab='Frequency')

# %%
distPlot(data=df, var='gdpPercap', title='GDP / capita',
         xlab='GDP / capita ($)', ylab='Frequency')

# %%
scatterPlot(data=df, varx='lifeExp', vary='gdpPercap',
            title='Life Expectancy vs GDP/Capita', xlab='lifeExp', ylab='gdpPercap')

# %%
df[['lifeExp','gdpPercap']].corr(method='pearson')

# %%
df[['lifeExp','gdpPercap']].corr(method='spearman')

# %%
df[['lifeExp','gdpPercap']].corr(method='kendall')

# %%
corr_df = df[['lifeExp','gdpPercap']].corr(method='spearman')
corr_df

#%%
corr_df.index.name = 'rowname'
corr_df.reset_index(inplace=True)
corr_df

# %%

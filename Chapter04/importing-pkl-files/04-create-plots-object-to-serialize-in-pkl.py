
import pandas as pd
import pickle
import matplotlib.pyplot as plt

population_df = pd.read_csv("population.csv")


selected_countries = ["Italy", "Sweden", "France", "Germany"]

selected_population_df = population_df.loc[ population_df['country'].isin(selected_countries) ]

nested_population_dict = {}
for c in selected_countries:
    nested_population_dict[c] = selected_population_df.loc[ population_df['country'] == c ].filter(['year', 'population']).reset_index(drop=True)

selected_country = "Sweden"
x = nested_population_dict[selected_country].year
y = nested_population_dict[selected_country].population

fig_handle = plt.figure()
plt.plot(x, y)
plt.title("Global population of " + selected_country)

fig_handle.show()


nested_population_plots_dict = {}
for c in selected_countries:
    tmp_df = selected_population_df.loc[ population_df['country'] == c ].filter(['year', 'population']).reset_index(drop=True)
    
    x = tmp_df.year
    y = tmp_df.population
    
    fig_handle = plt.figure()
    plt.plot(x, y)
    plt.title("Global population of " + c)

    nested_population_plots_dict[c] = fig_handle


pickle.dump( nested_population_plots_dict, open("nested_population_plots_dict.pkl", "wb") )


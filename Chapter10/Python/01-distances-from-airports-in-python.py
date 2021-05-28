# %%
import numpy as np
import pandas as pd
from pygeodesy import formy as frm
from pygeodesy.ellipsoidalKarney import LatLon as kLatLon

# %%
# Function that calculates the Karney distance
def karney(lat1, lng1, lat2, lng2):
    return kLatLon(lat1, lng1).distanceTo(kLatLon(lat2, lng2))

# Generalization of distance functions
def geodistance(lat1, lng1, lat2, lng2, func):
    return func(lat1, lng1, lat2, lng2)

def airportLatLongList(df, iata_code):
    return df[df['iata_code'] == iata_code][['latitude','longitude']].values.tolist()[0]

# %%
hotels_df = pd.read_excel(r'D:\<your-path>\Chapter10\hotels-ny.xlsx')
hotels_df.head()

# %%
airports_df = pd.read_csv(r'D:\<your-path>\Chapter10\airport-codes.csv')
airports_df.head()

# %%
# Coordinates are saved as a string, so we have to split them into two new columns
airports_df = pd.concat([
    airports_df.drop(['coordinates'], axis=1),
    airports_df['coordinates'].str.split(', ', expand=True).rename(columns={0:'longitude', 1:'latitude'}).astype(float)], axis=1)

airports_df.head()

# %%
jfk_lat, jfk_long  = airportLatLongList(airports_df, 'JFK')
lga_lat, lga_long = airportLatLongList(airports_df, 'LGA')

hotels_df['haversineDistanceFromJFK'] = np.vectorize(geodistance)(
    hotels_df['latitude'],
    hotels_df['longitude'],
    jfk_lat,
    jfk_long,
    func=frm.haversine)

hotels_df['karneyDistanceFromJFK'] = np.vectorize(geodistance)(
    hotels_df['latitude'],
    hotels_df['longitude'],
    jfk_lat,
    jfk_long,
    func=karney)

hotels_df['haversineDistanceFromLGA'] = np.vectorize(geodistance)(
    hotels_df['latitude'],
    hotels_df['longitude'],
    lga_lat,
    lga_long,
    func=frm.haversine)

hotels_df['karneyDistanceFromLGA'] = np.vectorize(geodistance)(
    hotels_df['latitude'],
    hotels_df['longitude'],
    lga_lat,
    lga_long,
    func=karney)

hotels_df.head()

# %%
hotels_df[['name','haversineDistanceFromJFK','karneyDistanceFromJFK','haversineDistanceFromLGA','karneyDistanceFromLGA']]

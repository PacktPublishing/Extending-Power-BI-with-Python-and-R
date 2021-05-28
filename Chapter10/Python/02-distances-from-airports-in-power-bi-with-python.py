
import numpy as np
from pygeodesy import formy as frm
from pygeodesy.ellipsoidalKarney import LatLon as kLatLon

pd = pandas

# Function that calculates the Karney distance
def karney(lat1, lng1, lat2, lng2):
    return kLatLon(lat1, lng1).distanceTo(kLatLon(lat2, lng2))

# Generalization of distance functions
def geodistance(lat1, lng1, lat2, lng2, func):
    return func(lat1, lng1, lat2, lng2)

def airportLatLongList(df, iata_code):
    return df[df['iata_code'] == iata_code][['latitude','longitude']].values.tolist()[0]

airports_df = pd.read_csv(r'D:\<your-path>\Chapter10\airport-codes.csv')

# Coordinates are saved as a string, so we have to split them into two new columns
airports_df = pd.concat([
    airports_df.drop(['coordinates'], axis=1),
    airports_df['coordinates'].str.split(', ', expand=True).rename(columns={0:'longitude', 1:'latitude'}).astype(float)], axis=1)

jfk_lat, jfk_long  = airportLatLongList(airports_df, 'JFK')
lga_lat, lga_long = airportLatLongList(airports_df, 'LGA')

dataset['haversineDistanceFromJFK'] = np.vectorize(geodistance)(
    dataset['latitude'],
    dataset['longitude'],
    jfk_lat,
    jfk_long,
    func=frm.haversine)

dataset['karneyDistanceFromJFK'] = np.vectorize(geodistance)(
    dataset['latitude'],
    dataset['longitude'],
    jfk_lat,
    jfk_long,
    func=karney)

dataset['haversineDistanceFromLGA'] = np.vectorize(geodistance)(
    dataset['latitude'],
    dataset['longitude'],
    lga_lat,
    lga_long,
    func=frm.haversine)

dataset['karneyDistanceFromLGA'] = np.vectorize(geodistance)(
    dataset['latitude'],
    dataset['longitude'],
    lga_lat,
    lga_long,
    func=karney)

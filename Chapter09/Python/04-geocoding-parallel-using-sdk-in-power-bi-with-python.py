
import os
import geocoder
import pandas as pd
import dask.dataframe as dd
import time


def bing_geocode_via_address(address):
    r = geocoder.bing(address, key = AUTH_KEY)
    
    return r.address, r.lat, r.lng, r.json, r.status, r.url


def enrich_with_geocoding(passed_row, col_name):
    address_value = str(passed_row[col_name])
    
    address_formatted, address_lat, address_lng, text, status, url = bing_geocode_via_address(address_value)
    
    passed_row['formattedAddress'] = address_formatted
    passed_row['latitude'] = address_lat
    passed_row['longitude'] = address_lng
    passed_row['text'] = text
    passed_row['status'] = status
    passed_row['url'] = url
    
    return passed_row



AUTH_KEY = os.environ.get('BINGMAPS_API_KEY')

ddf_orig = dd.read_csv(r'D:\LZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter09\geocoding_test_data.csv',
                       encoding='latin-1')

ddf = ddf_orig[['full_address']]

ddf = ddf.repartition(npartitions=os.cpu_count()*2)

enriched_ddf = ddf.apply(enrich_with_geocoding, axis=1, col_name='full_address',
                         meta={'full_address': 'string', 'formattedAddress': 'string',
                               'latitude': 'float64', 'longitude': 'float64', 'text': 'string',
                               'status': 'string', 'url': 'string'})

enriched_df = enriched_ddf.compute()

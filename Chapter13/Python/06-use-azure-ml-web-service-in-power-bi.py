
# %%
import urllib.request
import json
import pandas as pd
from pycaret.classification import *


# %%
def consumeAzureMLEndpoint(url, api_key, obs_df):
    # Request data goes here
    json_records_str = obs_df.to_json(orient='records')
    data_str = f'{{"data":{json_records_str}}}'
    data = json.loads(data_str)

    headers = {'Content-Type':'application/json', 'Authorization':('Bearer '+ api_key)}
    body = str.encode(json.dumps(data))

    req = urllib.request.Request(url, body, headers)

    try:
        response = urllib.request.urlopen(req)
        j = json.loads(json.loads(response.read()))
        result = pd.json_normalize(j,record_path='result').set_axis(['predicted_label'],axis=1)

    except urllib.error.HTTPError as error:
        print("The request failed with status code: " + str(error.code))

        # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
        print(error.info())
        print(json.loads(error.read().decode("utf8", 'ignore')))

        result = None
    
    return result

# %%
url = '<your-endpoint-url>'
api_key = '<your-endpoint-key>' # Replace this with the API key for the web service

# %%
# Uncomment this code if you're not using it in Power BI
# in order to load the imputed test dataset
# dataset = pd.read_csv(r'C:\<your-path>\Chapter13\titanic-test.csv',
#                       index_col=False)

obs = dataset.drop('Survived',axis=1)

# %%
predictions = consumeAzureMLEndpoint(url, api_key, obs)
predictions

# %%
scored_df = pd.concat([dataset, predictions],axis=1)
scored_df

# %%

# %%
import urllib.request
import json
import os
#import ssl

#%%
# def allowSelfSignedHttps(allowed):
#     # bypass the server certificate verification on client side
#     if allowed and not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None):
#         ssl._create_default_https_context = ssl._create_unverified_context

# %%
#allowSelfSignedHttps(True) # this line is needed if you use self-signed certificate in your scoring service.

# Request data goes here
data = {
    "data":
    [
        {
            "Pclass":"1","Sex":"1","Age":"18.0","SibSp":"1","Parch":"0","Fare":"108.9","Embarked":"0"
        }
    ],
    "method" : "predict_proba"
}

body = str.encode(json.dumps(data))
body

# %%
url = 'http://ea804dcd-bbc2-484a-98c1-9cd4d0b89e47.westeurope.azurecontainer.io/score'
api_key = 'Ikrql0fZJf0poy8UOKUGJX5Vqhv8VNH7' # Replace this with the API key for the web service
headers = {'Content-Type':'application/json', 'Authorization':('Bearer '+ api_key)}

req = urllib.request.Request(url, body, headers)

try:
    response = urllib.request.urlopen(req)

    result = response.read()
    print(result)
except urllib.error.HTTPError as error:
    print("The request failed with status code: " + str(error.code))

    # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
    print(error.info())
    print(json.loads(error.read().decode("utf8", 'ignore')))
# %%

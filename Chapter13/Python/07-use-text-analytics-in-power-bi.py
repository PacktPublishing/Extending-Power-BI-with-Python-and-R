
# %%
import pandas as pd
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential

# %%
def authenticate_client():
    ta_credential = AzureKeyCredential(key)
    text_analytics_client = TextAnalyticsClient(
            endpoint=endpoint, 
            credential=ta_credential)
    return text_analytics_client


def sentimentOfColumn(df,col_name):
    
    client = authenticate_client()

    all_documents = df[col_name].tolist()

    # Group all documents in groups of N.
    # N is 10 as the max number of documents allowed at a time for the free account is 10
    N = 10
    grouped_docs_list = [all_documents[n:n+N] for n in range(0, len(all_documents), N)]

    # For each group of documents (i.e. comments), consume the text analytics API
    # in order to get the sentiment analysis of each comment (that can be made of more sentences).
    sentiment_df_lst = []

    for docs_group in grouped_docs_list:
        for doc_idx, _ in enumerate(docs_group):
            response = client.analyze_sentiment(documents=docs_group)[doc_idx]

            tmp_data = [{
                'comment_sentiment': format(response.sentiment),
                'overall_positive_score': response.confidence_scores.positive,
                'overall_neutral_score': response.confidence_scores.neutral,
                'overall_negative_score': response.confidence_scores.negative
            }]
            #print(tmp_data)
            tmp_df = pd.DataFrame.from_records(tmp_data)

            # append the temporary dataframe to the sentiment_df_lst list of dataframes
            sentiment_df_lst.append(tmp_df)

    # Merge all the sentiment_df_lst dataframes into the sentiment_df dataframe
    sentiment_df = pd.concat(sentiment_df_lst, ignore_index=True)
    
    return pd.concat([df,sentiment_df],axis=1)

# %%
# Uncomment this if not using in Power BI
# dataset = pd.read_csv(r'C:\<your-path>\Chapter13\FabrikamComments.csv')
# dataset

# %%
key = "<your-text-analytics-key>"
endpoint = "<your-text-analytics-url>"

sentiment_enriched_df = sentimentOfColumn(dataset, col_name='comment')
sentiment_enriched_df

# %%

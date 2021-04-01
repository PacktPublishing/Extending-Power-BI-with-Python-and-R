
import pandas as pd

from presidio_analyzer import AnalyzerEngine, PatternRecognizer
from presidio_anonymizer import AnonymizerEngine
from presidio_anonymizer.entities import AnonymizerConfig

import secrets
import string


def generateToken(len):
    alphabet = string.ascii_letters + string.digits
    tkn = ''.join(secrets.choice(alphabet) for i in range(len))
    return tkn


# Function used to anonymize a text containing emails
def anonymizeEmail(text_to_anonymize): 
    analyzer_results = analyzer.analyze(text=text_to_anonymize, entities=["EMAIL_ADDRESS"], language='en')

    anonymized_results = anonymizer.anonymize(
        text=text_to_anonymize,
        analyzer_results=analyzer_results,    
        anonymizers_config={"EMAIL_ADDRESS": AnonymizerConfig("replace", {"new_value": generateToken(20)})}
    )

    return anonymized_results

# Function used to anonymize a text containing names
def anonymizeName(text_to_anonymize): 
    analyzer_results = analyzer.analyze(text=text_to_anonymize, entities=["PERSON"], language='en')

    anonymized_results = anonymizer.anonymize(
        text=text_to_anonymize,
        analyzer_results=analyzer_results,    
        anonymizers_config={"PERSON": AnonymizerConfig("replace", {"new_value": generateToken(20)})}
    )

    return anonymized_results


# For testing purpose you can load the Excel content directly here
# # Load the Excel content in a dataframe
# dataset = pd.read_excel(r'D:\LZavarella\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R\Chapter06\CustomersCreditCardAttempts.xlsx')


# Initialize Presidio's analyzer and anonymizer
# https://microsoft.github.io/presidio/supported_entities/
analyzer = AnalyzerEngine()
anonymizer = AnonymizerEngine()

# Create a copy of the source dataset
df = dataset.copy()

# Apply the function anonymizeName for each value of the Name column
df.Name = df.Name.apply(lambda x: anonymizeName(x))

# Apply the function anonymizeEmail for each value of the Email column
df.Email = df.Email.apply(lambda x: anonymizeEmail(x))

# Column Notes is 'object' data type as it contains lot of NaN and
# Pandas doesn't recognize it as string. So it has to be cast to string
# in order to be anonymized. Then replace it with its anonymization
df.Notes = df.Notes.astype('str').apply(lambda x: anonymizeName(x) )
df.Notes = df.Notes.astype('str').apply(lambda x: anonymizeEmail(x) )

# # Prevent Pandas to truncate strings in cells
# pd.set_option('display.max_colwidth', None)

# # Show both the dataframes
# dataset
# df

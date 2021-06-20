import os
import pickle
import pandas as pd

from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine

from faker import Faker
from faker.providers import internet


# Function used to pseudonymize a text containing emails
def anonymizeEmail(text_to_anonymize, country):
    # Initialize Faker
    fake = Faker(faker_locales_dict[country])
    fake.add_provider(internet)

    analyzer_results = analyzer.analyze(text=text_to_anonymize, entities=["EMAIL_ADDRESS"], language='en')
    
    matched_emails = {}
    for match in analyzer_results:
        email = text_to_anonymize[match.start:match.end]
        
        if email not in emails_dict:
            fake_email = fake.safe_email()

            while (fake_email in emails_dict.values()) or (fake_email in emails_dict):
                fake_email = fake.safe_email()
                
            emails_dict[email] = fake_email
            matched_emails[email] = fake_email
        else:
            fake_email = emails_dict[email]
            matched_emails[email] = fake_email

    anonymized_result = text_to_anonymize
    for email in matched_emails:
        anonymized_result = anonymized_result.replace(email, matched_emails[email])

    return anonymized_result

# Function used to pseudonymize a text containing names
def anonymizeName(text_to_anonymize, country):
    # Initialize Faker
    fake = Faker(faker_locales_dict[country])
    
    analyzer_results = analyzer.analyze(text=text_to_anonymize, entities=["PERSON"], language='en')

    matched_names = {}
    for match in analyzer_results:
        name = text_to_anonymize[match.start:match.end]
        
        if name not in names_dict:
            fake_name = fake.name()
            
            while (fake_name in names_dict.values()) or (fake_name in names_dict):
                fake_name = fake.name()

            names_dict[name] = fake_name
            matched_names[name] = fake_name
        else:
            fake_name = names_dict[name]
            matched_names[name] = fake_name

    anonymized_result = text_to_anonymize
    for name in matched_names:
        anonymized_result = anonymized_result.replace(name, matched_names[name])

    return anonymized_result


# For testing purpose you can load the Excel content directly here.
# Just uncomment the following 2 lines.
# # Load the Excel content in a dataframe
# dataset = pd.read_excel(r'D:\<your-path>\Chapter06\CustomersCreditCardAttempts.xlsx')

# Load mapping dictionaries from PKL files if they exist, otherwise create empty dictionaries
pkls_path = r'D:\<your-path>\Chapter06\pkls'
emails_dict_pkl_path = os.path.join(pkls_path, 'emails_dict.pkl')
names_dict_pkl_path = os.path.join(pkls_path, 'names_dict.pkl')

if os.path.isfile(emails_dict_pkl_path):
    emails_dict = pickle.load( open(emails_dict_pkl_path, "rb") )
else:
    emails_dict = {}

if os.path.isfile(names_dict_pkl_path):
    names_dict = pickle.load( open(names_dict_pkl_path, "rb") )
else:
    names_dict = {}

# Define locale and language dictionaries
faker_locales_dict = {'UNITED STATES': 'en_US', 'ITALY': 'it_IT', 'GERMANY': 'de_DE'}



# Initialize Presidio's analyzer and anonymizer
# https://microsoft.github.io/presidio/supported_entities/
analyzer = AnalyzerEngine()
anonymizer = AnonymizerEngine()

# Create a copy of the source dataset
df = dataset.copy()

# Apply the function anonymizeName for each value of the Name column
df.Name = pd.Series( [anonymizeName(text, country) for (text, country) in zip(df['Name'], df['Country'])] )

# Apply the function anonymizeEmail for each value of the Email column
df.Email = pd.Series( [anonymizeEmail(text, country) for (text, country) in zip(df['Email'], df['Country'])] )

# Column Notes is 'object' data type as it contains lot of NaN and
# Pandas doesn't recognize it as string. So it has to be cast to string
# in order to be anonymized. Then replace it with its anonymization
df.Notes = pd.Series( [anonymizeName(text, country) for (text, country) in zip(df['Notes'].astype('str'), df['Country'])] )
df.Notes = pd.Series( [anonymizeEmail(text, country) for (text, country) in zip(df['Notes'].astype('str'), df['Country'])] )


# # Prevent Pandas to truncate strings in cells
# pd.set_option('display.max_colwidth', None)

# # Show both the dataframes
# dataset
# df

# Write emails and names dictionaries to PKL files
pickle.dump( emails_dict, open(emails_dict_pkl_path, "wb") )
pickle.dump( names_dict, open(names_dict_pkl_path, "wb") )

import pandas as pd
import re

df = dataset

# You can choose the format of dates you can find in your dataset.
# 
# The possible choices are: 'dd-mm-yyyy', 'mm-dd-yyyy' and 'yyyy-mm-dd'.
# 
# All the regular expressions work for all their variants (for example, 7-6-2021),
# and for both '-' and '/' as separators.
date_format = 'mm-dd-yyyy'

if date_format == 'dd-mm-yyyy':
    regex_dates_having_day_31 = r'(?:31[\-\/](?:(?:0?[13578])|(1[02]))[\-\/](19|20)?\d\d)'
    regex_non_leap_dates_having_days_29_30 = r'(?:(?:29|30)[\-\/](?:(?:0?[13-9])|(?:1[0-2]))[\-\/](?:19|20)?\d\d)'
    regex_leap_dates_having_day_29 = r'(?:29[\-\/]0?2[\-\/](?:19|20)?(?:(?:[02468][048])|(?:[13579][26])))'
    regex_remaining_dates = r'(?:(?:(?:1\d)|(?:0?[1-9])|(?:2[0-8]))[\-\/](?:(?:0?[1-9])|(?:1[0-2]))[\-\/](?:19|20)?\d\d)'
elif date_format == 'mm-dd-yyyy':
    regex_dates_having_day_31 = r'(?:(?:(?:0?[13578])|(?:1[02]))[\-\/]31[\-\/](?:19|20)?\d\d)'
    regex_non_leap_dates_having_days_29_30 = r'(?:(?:(?:0?[13-9])|(?:1[0-2]))[\-\/](?:29|30)[\-\/](?:19|20)?\d\d)'
    regex_leap_dates_having_day_29 = r'(?:0?2[\-\/]29[\-\/](?:19|20)?(?:(?:[02468][048])|(?:[13579][26])))'
    regex_remaining_dates = r'(?:(?:(?:0?[1-9])|(?:1[0-2]))[\-\/](?:(?:1\d)|(?:0?[1-9])|(?:2[0-8]))[\-\/](?:19|20)?\d\d)'
elif date_format == 'yyyy-mm-dd':
    regex_dates_having_day_31 = r'(?:(19|20)?\d\d[\-\/](?:(?:0?[13578])|(1[02]))[\-\/]31)'
    regex_non_leap_dates_having_days_29_30 = r'(?:(?:(?:19|20)?\d\d)[\-\/](?:(?:0?[13-9])|(?:1[0-2]))[\-\/](?:29|30))'
    regex_leap_dates_having_day_29 = r'(?:(?:19|20)?(?:(?:[02468][048])|(?:[13579][26]))[\-\/]0?2[\-\/]29)'
    regex_remaining_dates = r'(?:(?:(?:19|20)?\d\d)[\-\/](?:(?:0?[1-9])|(?:1[0-2]))[\-\/](?:(?:1\d)|(?:0?[1-9])|(?:2[0-8])))'
else:
    quit() # in this case, Power BI won't show any dataset on the next step

pattern = r'^(?:{0}|{1}|{2}|{3})$'.format(regex_dates_having_day_31, regex_non_leap_dates_having_days_29_30, regex_leap_dates_having_day_29, regex_remaining_dates)

df['isValidDateFromRegex'] = df['BannedDate'].str.match(pattern).astype(int)

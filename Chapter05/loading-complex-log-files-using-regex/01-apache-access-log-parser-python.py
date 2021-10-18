import pandas as pd
import re


with open('D:/<your-path>/Chapter05/loading-complex-log-files-using-regex/apache_logs.txt', 'r') as f:
    access_log_lines = f.readlines()

# Define a regex for the information (variables) contained in each row of the log
regex_parts = [
    r'(?P<hostName>\S+)',                               # remote hostname (IP address)
    r'\S+',                                             # remote logname (you’ll find a dash if empty; not used in the sample file)
    r'(?P<userName>\S+)',                               # remote user if the request was authenticated (you’ll find a dash if empty)
    r'\[(?P<requestDateTime>[\w:/]+\s[+\-]\d{4})\]',    # datetime the request was received, in the format [18/Sep/2011:19:18:28 -0400]
    r'"(?P<requestContent>(\S+)\s?(\S+)?\s?(\S+)?)"',   # first line of the request made to the server between double quotes "%r"
    r'(?P<requestStatus>\d{3}|-)',                      # HTTP status code for the request
    r'(?P<responseSizeBytes>\d+|-)',                    # size of response in bytes, excluding HTTP headers (can be '-')
    r'"(?P<requestReferrer>[^"]*)"',                    # Referer HTTP request header, that contains the absolute or partial address of the page making the request
    r'"(?P<requestAgent>[^"]*)?"',                      # User-Agent HTTP request header, that contains a string that identifies the application, operating system, vendor, and/or version of the requesting user agent
]

# Join all the regex parts using '\s+' as separator and
# append '$' at the end
pattern = re.compile(r'\s+'.join(regex_parts) + r'$')

# Scrape data from each line of the log file into a structured dictionary and
# store all the dictionaries into a list.
# Keep track also of the line index in case of error
log_data = []
lines_error = []

num_errors = 0
num_line = 1

for line in access_log_lines:    
    try:
        # match the pattern to the line and append to log_data a dictionary
        # with the group name as keys and the matched string as value
        log_data.append(pattern.match(line).groupdict())
    except:
        num_errors += 1
        lines_error.append(num_line)
    
    num_line += 1

# # In case of debug
# print(f'Errors: {num_errors}')

# for err_line in lines_error:
#     print(f'Errors in line: {err_line}')

# Create a pandas dataframe starting from the log_data list
df = pd.DataFrame(log_data)

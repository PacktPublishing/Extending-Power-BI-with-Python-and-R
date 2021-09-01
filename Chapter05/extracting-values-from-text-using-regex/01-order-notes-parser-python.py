import pandas as pd
import regex


# # For debugging purpose
# # To load an xlsx file in Python, you need to install also the package: openpyxl
# dataset = pd.read_excel (r'D:\<your>\<local>\<path>\OrderNotes.xlsx', engine='openpyxl')

# Define a regex for the information (variables) contained in each row of the log
currency_regex  = r'(?:EUR|€)'
amount_regex    = r'(?P<RefundAmount>\d{1,}\.?\d{0,2})'
reason_regex    = r'(?P<RefundReason>.*?)'
date_regex      = r'(?P<RefundDate>\d{2}[\-\/]\d{2}[\-\/]\d{4})'
separator_regex = r'(?:\s+)?-?(?:\s+)?'


regex_parts_alternative_1 = [
    currency_regex,
    amount_regex,
    reason_regex,
    date_regex
]

regex_parts_alternative_2 = [
    amount_regex,
    currency_regex,
    reason_regex,
    date_regex
]

regex_parts_alternative_3 = [
    date_regex,
    currency_regex,
    amount_regex,
    reason_regex
]

regex_parts_alternative_4 = [
    date_regex,
    amount_regex,
    currency_regex,
    reason_regex
]


regex_parts_template = [
    '^(?:',
    f'(?:{separator_regex.join(regex_parts_alternative_1)}{separator_regex})',
    '|',
    f'(?:{separator_regex.join(regex_parts_alternative_2)}{separator_regex})',
    '|',
    f'(?:{separator_regex.join(regex_parts_alternative_3)}{separator_regex})',
    '|',
    f'(?:{separator_regex.join(regex_parts_alternative_4)}{separator_regex})',
    ')$'
]

pattern = regex.compile(r''.join(regex_parts_template))


extracted_values = []
num_line = 0
lines_error = []

for note in dataset.Notes.tolist():
    try:
        extracted_values.append( regex.match(pattern, note).groupdict() )
    except:
        lines_error.append(num_line)
    
    num_line += 1


df = pd.concat([dataset, pd.DataFrame(extracted_values)], axis=1)

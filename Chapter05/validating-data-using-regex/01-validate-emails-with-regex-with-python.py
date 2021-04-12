import pandas as pd
import re

df = dataset

regex_local_part = r'([^<>()[\]\\.,;:\s@\""]+(\.[^<>()[\]\\.,;:\s@\""]+)*)|(\"".+\"")'
regex_domain_name = r'(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,})'
regex_domain_ip_address = r'(\[?[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\]?)'

pattern = r'^({0})@({1}|{2})$'.format(regex_local_part, regex_domain_name, regex_domain_ip_address)

df['isEmailValidFromRegex'] = df['Email'].str.match(pattern).astype(int)

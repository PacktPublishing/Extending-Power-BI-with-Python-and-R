library(readr)
library(namedCapture)


access_log_lines <- read_lines('D:/<your-path>/Chapter05/loading-complex-log-files-using-regex/apache_logs.txt')


# Define a regex for the information (variables) contained in each row of the log
regex_parts <- c(
    r'{(?P<hostName>\S+)}'                              # remote hostname (IP address)
  , r'{\S+}'                                            # remote logname (you’ll find a dash if empty; not used in the sample file)
  , r'{(?P<userName>\S+)}'                              # remote user if the request was authenticated (you’ll find a dash if empty)
  , r'{\[(?P<requestDateTime>[\w:/]+\s[+\-]\d{4})\]}'   # datetime the request was received, in the format [18/Sep/2011:19:18:28 -0400]
  , r'{"(?P<requestContent>\S+\s?\S+?\s?\S+?)"}'        # first line of the request made to the server between double quotes "%r"
  , r'{(?P<requestStatus>\d{3}|-)}'                     # HTTP status code for the request
  , r'{(?P<responseSizeBytes>\d+|-)}'                   # size of response in bytes, excluding HTTP headers (can be '-')
  , r'{"(?P<requestReferrer>[^"]*)"}'                   # Referer HTTP request header, that contains the absolute or partial address of the page making the request
  , r'{"(?P<requestAgent>[^"]*)?"}'                     # User-Agent HTTP request header, that contains a string that identifies the application, operating system, vendor, and/or version of the requesting user agent
)

# Join all the regex parts using '\s+' as separator and
# append '$' at the end
pattern <- paste0( paste(regex_parts, collapse = r'{\s+}'), '$' )

df <- as.data.frame( str_match_named( access_log_lines, pattern = pattern ) )

# Location of Apache Error Log
log_location_linux = '/var/log/httpd/error_log'
log_location_windows = 'C:\Apache24\logs\error.log'

# Regular expression to filter for timestamp in Apache Error Log
#
# Default timestamp format: (example: [Thu Nov 09 09:04:38.912314 2017])
log_date_regex = "\[([A-Z][a-z]{2} [A-z][a-z]{2} \d{1,2} \d{1,2}\:\d{1,2}\:\d{1,2}\.\d+? \d{4})\]"
#
# Reverse format: (example: [2017-11-09 08:25:03.002312])
#log_date_regex = "\[([0-9-]{10} [0-9:.]{15})\]"

# Date format matching the timestamp format used by Apache 
# in order to generate matching timestamp ourself
#
# Default timestamp format: (example: see above)
log_date_format = "%a %b %d %H:%M:%S.%f %Y"
#
# Reverse format: (example: see above)
#log_date_format = "%Y-%m-%d %H:%M:%S.%f"

# Location of Apache/Nginx Error Log
log_location_linux = '/var/log/apache2/error.log'
#log_location_linux = '/var/log/nginx/error.log'
#log_location_windows = 'C:\Apache24\logs\error.log'

# Regular expression to filter for timestamp in Apache Error Log
#
# Default Apache timestamp format: (example: [Thu Nov 09 09:04:38.912314 2017])
log_date_regex = "\[([A-Z][a-z]{2} [A-z][a-z]{2} \d{1,2} \d{1,2}\:\d{1,2}\:\d{1,2}\.\d+? \d{4})\]"

# Regular expression to filter for timestamp in Apache Error Log
#
# Default Nginx timestamp format: (example: 2017/11/09 09:04:38)
#log_date_regex = "(\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2})"

#
# Reverse format: (example: [2017-11-09 08:25:03.002312])
#log_date_regex = "\[([0-9-]{10} [0-9:.]{15})\]"

# Date format matching the timestamp format used by Apache
# in order to generate matching timestamp ourself
#
# Default Apache timestamp format: (example: see above)
log_date_format = "%a %b %d %H:%M:%S.%f %Y"
#
# Default Nginx timestamp format: (example: see above)
# Note, that Nginx log doesn't contain the microsecond, but
# test appends it to the end, so it needs to parse then
#log_date_format = "%Y/%m/%d %H:%M:%S.%f"

#
# Reverse format: (example: see above)
#log_date_format = "%Y-%m-%d %H:%M:%S.%f"

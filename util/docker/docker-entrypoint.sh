#!/bin/bash

# Paranoia Level
$(python <<EOF
import re
import os
out=re.sub('(#SecAction[\S\s]{7}id:900000[\s\S]*tx\.paranoia_level=1\")','SecAction \\\\\n  \"id:900000, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:tx.paranoia_level='+os.environ['PARANOIA']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Executing Paranoia Level
$(python <<EOF
import re
import os
if "EXECUTING_PARANOIA" in os.environ: 
   out=re.sub('(#SecAction[\S\s]{7}id:900001[\s\S]*tx\.executing_paranoia_level=1\")','SecAction \\\\\n  \"id:900001, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:tx.executing_paranoia_level='+os.environ['EXECUTING_PARANOIA']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Enforce Body Processor URLENCODED
$(python <<EOF
import re
import os
if "ENFORCE_BODYPROC_URLENCODED" in os.environ:
   out=re.sub('(#SecAction[\S\s]{7}id:900010[\s\S]*tx\.enforce_bodyproc_urlencoded=1\")','SecAction \\\\\n  \"id:900010, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:tx.enforce_bodyproc_urlencoded='+os.environ['ENFORCE_BODYPROC_URLENCODED']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Inbound and Outbound Anomaly Score
$(python <<EOF
import re
import os
out=re.sub('(#SecAction[\S\s]{6}id:900110[\s\S]*tx\.outbound_anomaly_score_threshold=4\")','SecAction \\\\\n  \"id:900110, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:tx.inbound_anomaly_score_threshold='+os.environ['ANOMALYIN']+','+'  \\\\\n   setvar:tx.outbound_anomaly_score_threshold='+os.environ['ANOMALYOUT']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# HTTP methods that a client is allowed to use.
$(python <<EOF
import re
import os
if "ALLOWED_METHODS" in os.environ:
   out=re.sub('(#SecAction[\S\s]{6}id:900200[\s\S]*\'tx\.allowed_methods=[A-Z\s]*\'\")','SecAction \\\\\n  \"id:900200, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:\'tx.allowed_methods='+os.environ['ALLOWED_METHODS']+'\'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Content-Types that a client is allowed to send in a request.
$(python <<EOF
import re
import os
if "ALLOWED_REQUEST_CONTENT_TYPE" in os.environ:
   out=re.sub('(#SecAction[\S\s]{6}id:900220[\s\S]*\'tx.allowed_request_content_type=[a-z|\-\+\/]*\'\")','SecAction \\\\\n  \"id:900220, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:\'tx.allowed_request_content_type='+os.environ['ALLOWED_REQUEST_CONTENT_TYPE']+'\'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Content-Types charsets that a client is allowed to send in a request.
$(python <<EOF
import re
import os
if "ALLOWED_REQUEST_CONTENT_TYPE_CHARSET" in os.environ:
   out=re.sub('(#SecAction[\S\s]{6}id:900270[\s\S]*\'tx.allowed_request_content_type_charset=[|\-a-z0-9]*\'\")','SecAction \\\\\n  \"id:900270, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:\'tx.allowed_request_content_type_charset='+os.environ['ALLOWED_REQUEST_CONTENT_TYPE_CHARSET']+'\'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Allowed HTTP versions.
$(python <<EOF
import re
import os
if "ALLOWED_HTTP_VERSIONS" in os.environ:
   out=re.sub('(#SecAction[\S\s]{6}id:900230[\s\S]*\'tx.allowed_http_versions=[HTP012\/\.\s]*\'\")','SecAction \\\\\n  \"id:900230, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:\'tx.allowed_http_versions='+os.environ['ALLOWED_HTTP_VERSIONS']+'\'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Forbidden file extensions.
$(python <<EOF
import re
import os
if "RESTRICTED_EXTENSIONS" in os.environ:
   out=re.sub('(#SecAction[\S\s]{6}id:900240[\s\S]*\'tx.restricted_extensions=[\.a-z\s\/]*\/\'\")','SecAction \\\\\n  \"id:900240, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:\'tx.restricted_extensions='+os.environ['RESTRICTED_EXTENSIONS']+'\'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Forbidden request headers.
$(python <<EOF
import re
import os
if "RESTRICTED_HEADERS" in os.environ:
   out=re.sub('(#SecAction[\S\s]{6}id:900250[\s\S]*\'tx.restricted_headers=[a-z\s\/\-]*\'\")','SecAction \\\\\n  \"id:900250, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:\'tx.restricted_headers='+os.environ['RESTRICTED_HEADERS']+'\'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# File extensions considered static files.
$(python <<EOF
import re
import os
if "STATIC_EXTENSIONS" in os.environ:
   out=re.sub('(#SecAction[\S\s]{6}id:900260[\s\S]*\'tx.static_extensions=\/[a-z\s\/\.]*\'\")','SecAction \\\\\n  \"id:900260, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:\'tx.static_extensions='+os.environ['STATIC_EXTENSIONS']+'\'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Block request if number of arguments is too high
$(python <<EOF
import re
import os
if "MAX_NUM_ARGS" in os.environ: 
   out=re.sub('(#SecAction[\S\s]{6}id:900300[\s\S]*tx\.max_num_args=255\")','SecAction \\\\\n \"id:900300, \\\\\n phase:1, \\\\\n nolog, \\\\\n pass, \\\\\n t:none, \\\\\n setvar:tx.max_num_args='+os.environ['MAX_NUM_ARGS']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Block request if the length of any argument name is too high
$(python <<EOF
import re
import os
if "ARG_NAME_LENGTH" in os.environ: 
   out=re.sub('(#SecAction[\S\s]{6}id:900310[\s\S]*tx\.arg_name_length=100\")','SecAction \\\\\n \"id:900310, \\\\\n phase:1, \\\\\n nolog, \\\\\n pass, \\\\\n t:none, \\\\\n setvar:tx.arg_name_length='+os.environ['ARG_NAME_LENGTH']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Block request if the length of any argument value is too high
$(python <<EOF
import re
import os
if "ARG_LENGTH" in os.environ: 
   out=re.sub('(#SecAction[\S\s]{6}id:900320[\s\S]*tx\.arg_length=400\")','SecAction \\\\\n \"id:900320, \\\\\n phase:1, \\\\\n nolog, \\\\\n pass, \\\\\n t:none, \\\\\n setvar:tx.arg_length='+os.environ['ARG_LENGTH']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Block request if the total length of all combined arguments is too high
$(python <<EOF
import re
import os
if "TOTAL_ARG_LENGTH" in os.environ: 
   out=re.sub('(#SecAction[\S\s]{6}id:900330[\s\S]*tx\.total_arg_length=64000\")','SecAction \\\\\n \"id:900330, \\\\\n phase:1, \\\\\n nolog, \\\\\n pass, \\\\\n t:none, \\\\\n setvar:tx.total_arg_length='+os.environ['TOTAL_ARG_LENGTH']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Block request if the total length of all combined arguments is too high
$(python <<EOF
import re
import os
if "MAX_FILE_SIZE" in os.environ: 
   out=re.sub('(#SecAction[\S\s]{6}id:900340[\s\S]*tx\.max_file_size=1048576\")','SecAction \\\\\n \"id:900340, \\\\\n phase:1, \\\\\n nolog, \\\\\n pass, \\\\\n t:none, \\\\\n setvar:tx.max_file_size='+os.environ['MAX_FILE_SIZE']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

# Block request if the total size of all combined uploaded files is too high
$(python <<EOF
import re
import os
if "COMBINED_FILE_SIZES" in os.environ: 
   out=re.sub('(#SecAction[\S\s]{6}id:900350[\s\S]*tx\.combined_file_sizes=1048576\")','SecAction \\\\\n \"id:900350, \\\\\n phase:1, \\\\\n nolog, \\\\\n pass, \\\\\n t:none, \\\\\n setvar:tx.combined_file_sizes='+os.environ['COMBINED_FILE_SIZES']+'\"',open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','r').read())
   open('/etc/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)
EOF
) && \

if [ $WEBSERVER = "Apache" ]; then
  if [ ! -z $PROXY ]; then
    if [ $PROXY -eq 1 ]; then
      WEBSERVER_ARGUMENTS='-D crs_proxy'
      if [ -z "$UPSTREAM" ]; then
        export UPSTREAM=$(/sbin/ip route | grep ^default | perl -pe 's/^.*?via ([\d.]+).*/$1/g'):81
      fi
    fi
  fi
elif [ $WEBSERVER = "Nginx" ]; then
  WEBSERVER_ARGUMENTS=''
fi


exec "$@" $WEBSERVER_ARGUMENTS

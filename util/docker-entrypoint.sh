#!/bin/bash
if [ -z "$CRS_PATH" ]; then
    echo "Please set CRS_PATH env variable."
    exit 1
fi  
python -c "import re;import os;out=re.sub('(#SecAction[\S\s]*id:900000[\s\S]*paranoia_level=1\")','SecAction \\\\\n  \"id:900000, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:tx.paranoia_level='+os.environ['PARANOIA']+'\"',open('/etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf','r').read());open('/etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)" && \
python -c "import re;import os;out=re.sub('(#SecAction[\S\s]*id:900330[\s\S]*total_arg_length=64000\")','SecAction \\\\\n \"id:900330, \\\\\n phase:1, \\\\\n nolog, \\\\\n pass, \\\\\n t:none, \\\\\n setvar:tx.total_arg_length=64000\"',open('/etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf','r').read());open('/etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)" && \

exec "$@"

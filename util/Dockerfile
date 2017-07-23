FROM owasp/modsecurity:latest
MAINTAINER Chaim Sanders chaim.sanders@gmail.com

ARG PARANOIA=1

RUN dnf -y update

RUN dnf -y install python

RUN cd /opt && \
  wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz && \
  tar -xvzf v3.0.2.tar.gz && \
  cp -R /opt/owasp-modsecurity-crs-3.0.2/ /etc/httpd/modsecurity.d/owasp-crs/ && \
  mv /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf && \
  python -c "import re;import os;out=re.sub('(#SecAction[\S\s]*id:900000[\s\S]*paranoia_level=1\")','SecAction \\\\\n  \"id:900000, \\\\\n   phase:1, \\\\\n   nolog, \\\\\n   pass, \\\\\n   t:none, \\\\\n   setvar:tx.paranoia_level=${PARANOIA}\"',open('/etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf','r').read());open('/etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf','w').write(out)" && \
  cd /etc/httpd/modsecurity.d && \
  printf "include modsecurity.d/owasp-crs/crs-setup.conf\ninclude modsecurity.d/owasp-crs/rules/*.conf" > include.conf && \
  sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/httpd/modsecurity.d/modsecurity.conf

EXPOSE 80

CMD ["httpd", "-k", "start", "-D", "FOREGROUND"]



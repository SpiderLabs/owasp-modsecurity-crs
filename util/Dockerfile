FROM owasp/modsecurity:latest
MAINTAINER Chaim Sanders chaim.sanders@gmail.com

RUN dnf -y update

RUN cd /opt && \
  wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz && \
  tar -xvzf v3.0.2.tar.gz && \
  cp -R /opt/owasp-modsecurity-crs-3.0.2/ /etc/httpd/modsecurity.d/owasp-crs/ && \
  mv /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf && \
  cd /etc/httpd/modsecurity.d && \
  printf "include modsecurity.d/owasp-crs/crs-setup.conf\ninclude modsecurity.d/owasp-crs/rules/*.conf" > include.conf && \
  sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/httpd/modsecurity.d/modsecurity.conf

EXPOSE 80

CMD ["httpd", "-k", "start", "-D", "FOREGROUND"]



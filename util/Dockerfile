FROM owasp/modsecurity:v2_master
MAINTAINER Chaim Sanders chaim.sanders@gmail.com

ENV PARANOIA=1

RUN dnf -y update

RUN dnf -y install python

RUN cd /opt && \
  #wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz && \
  #tar -xvzf v3.0.2.tar.gz && \
  git clone https://github.com/csanders-git/owasp-modsecurity-crs owasp-modsecurity-crs-3.0.2 && \
  cp -R /opt/owasp-modsecurity-crs-3.0.2/ /etc/httpd/modsecurity.d/owasp-crs/ && \
  mv /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf && \
  cd /etc/httpd/modsecurity.d/owasp-crs/ && \
  git checkout v3.0/dev-za && \
  cd /etc/httpd/modsecurity.d && \
  printf "include modsecurity.d/owasp-crs/crs-setup.conf\ninclude modsecurity.d/owasp-crs/rules/*.conf" > include.conf && \
  sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/httpd/modsecurity.d/modsecurity.conf

COPY docker-entrypoint.sh /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["httpd", "-k", "start", "-D", "FOREGROUND"]

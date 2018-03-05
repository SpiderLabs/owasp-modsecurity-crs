FROM owasp/modsecurity:v2_master
MAINTAINER Chaim Sanders chaim.sanders@gmail.com

ENV PARANOIA=1

RUN dnf -y update

RUN dnf -y install python

RUN cd /opt && \
  git clone -b v3.1/dev https://github.com/SpiderLabs/owasp-modsecurity-crs owasp-modsecurity-crs-3.1 && \
  cp -R /opt/owasp-modsecurity-crs-3.1/ /etc/httpd/modsecurity.d/owasp-crs/ && \
  mv /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/httpd/modsecurity.d/owasp-crs/crs-setup.conf && \
  cd /etc/httpd/modsecurity.d && \
  printf "include modsecurity.d/owasp-crs/crs-setup.conf\ninclude modsecurity.d/owasp-crs/rules/*.conf" > include.conf && \
  sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/httpd/modsecurity.d/modsecurity.conf

COPY docker-entrypoint.sh /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["httpd", "-k", "start", "-D", "FOREGROUND"]

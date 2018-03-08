FROM owasp/modsecurity:v2-ubuntu-apache
MAINTAINER Chaim Sanders chaim.sanders@gmail.com

ARG COMMIT=v3.1/dev
ARG REPO=SpiderLabs/owasp-modsecurity-crs
ENV PARANOIA=1

RUN apt-get update && \
    apt-get -y install python git

RUN cd /opt && \
  git clone https://github.com/${REPO}.git owasp-modsecurity-crs-3.1 && \
  cd owasp-modsecurity-crs-3.1 && \
  git checkout -qf ${COMMIT} 

RUN cd /opt && \
  cp -R /opt/owasp-modsecurity-crs-3.1/ /etc/apache2/modsecurity.d/owasp-crs/ && \
  mv /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/apache2/modsecurity.d/owasp-crs/crs-setup.conf && \
  cd /etc/apache2/modsecurity.d && \
  printf "include modsecurity.d/owasp-crs/crs-setup.conf\ninclude modsecurity.d/owasp-crs/rules/*.conf" > include.conf && \
  sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/apache2/modsecurity.d/modsecurity.conf

COPY docker-entrypoint.sh /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]

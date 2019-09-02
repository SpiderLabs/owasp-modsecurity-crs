FROM owasp/modsecurity:2.9-apache
LABEL maintainer="Chaim Sanders <chaim.sanders@gmail.com>"

ARG COMMIT=v3.3/dev
ARG BRANCH=v3.3/dev
ARG REPO=SpiderLabs/owasp-modsecurity-crs
ENV WEBSERVER=Apache
ENV PARANOIA=1
ENV ANOMALYIN=5
ENV ANOMALYOUT=4

RUN apt-get update && \
  apt-get -y install python git ca-certificates iproute2 && \
  mkdir /opt/owasp-modsecurity-crs-3.2 && \
  cd /opt/owasp-modsecurity-crs-3.2 && \
  git init && \
  git remote add origin https://github.com/${REPO} && \
  git fetch --depth 1 origin ${BRANCH} && \
  git checkout ${COMMIT} && \
  mv crs-setup.conf.example crs-setup.conf && \
  ln -sv /opt/owasp-modsecurity-crs-3.2 /etc/modsecurity.d/owasp-crs && \
  printf "include /etc/modsecurity.d/owasp-crs/crs-setup.conf\ninclude /etc/modsecurity.d/owasp-crs/rules/*.conf" >> /etc/modsecurity.d/include.conf && \
  sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/modsecurity.d/modsecurity.conf

COPY httpd-logging-before-modsec.conf  /usr/local/apache2/conf/extra/httpd-logging-before-modsec.conf
COPY httpd-logging-after-modsec.conf   /usr/local/apache2/conf/extra/httpd-logging-after-modsec.conf
COPY docker-entrypoint.sh /

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]

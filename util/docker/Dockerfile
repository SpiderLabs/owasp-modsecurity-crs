FROM owasp/modsecurity:2.9-apache-ubuntu
LABEL maintainer="Chaim Sanders <chaim.sanders@gmail.com>"

ARG COMMIT=v3.2/dev
ARG REPO=SpiderLabs/owasp-modsecurity-crs
ENV PARANOIA=1

RUN apt-get update && \
  apt-get -y install python git ca-certificates iproute2 && \
  mkdir /opt/owasp-modsecurity-crs-3.2 && \
  cd /opt/owasp-modsecurity-crs-3.2 && \
  git init && \
  git remote add origin https://github.com/${REPO}.git && \
  git fetch --depth 1 origin ${COMMIT} && \
  git checkout FETCH_HEAD && \
  mv crs-setup.conf.example crs-setup.conf && \
  ln -sv /opt/owasp-modsecurity-crs-3.2 /etc/apache2/modsecurity.d/owasp-crs && \
  printf "include modsecurity.d/owasp-crs/crs-setup.conf\ninclude modsecurity.d/owasp-crs/rules/*.conf" > /etc/apache2/modsecurity.d/include.conf && \
  sed -i -e 's/SecRuleEngine DetectionOnly/SecRuleEngine On/g' /etc/apache2/modsecurity.d/modsecurity.conf && \
  a2enmod proxy proxy_http

COPY proxy.conf           /etc/apache2/modsecurity.d/proxy.conf
COPY docker-entrypoint.sh /

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apachectl", "-D", "FOREGROUND"]

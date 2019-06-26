FROM ubuntu:18.04

# Install dependencies from apt and then tidy up cache
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-security2 python-pip git nano vim curl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install ftw

RUN cd / && \
    git clone https://github.com/CRS-support/secrules_parsing && \
    pip install -r /secrules_parsing/requirements.txt

RUN rm -fr /usr/share/modsecurity-crs/ && \
    printf "include /etc/modsecurity/crs/crs-setup.conf\ninclude /etc/modsecurity/crs/rules/*.conf\n" >> /etc/modsecurity/include.conf && \
    cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf && \
    sed -i -e 's/SecRuleEngine .*/SecRuleEngine DetectionOnly/g' /etc/modsecurity/modsecurity.conf && \
    echo ServerName 127.0.0.1 >> /etc/apache2/apache2.conf && \
    echo Hello World > /var/www/html/index.html

ENTRYPOINT ["/bin/bash", "-c", "\
    cp /etc/modsecurity/crs/crs-setup.conf.example /etc/modsecurity/crs/crs-setup.conf && \
    echo 'SecAction id:900000,phase:1,nolog,pass,t:none,setvar:tx.paranoia_level=5' >> /etc/modsecurity/crs/crs-setup.conf && \
    apachectl start && \
    cd /etc/modsecurity/crs/ && \
    export PYTHONDONTWRITEBYTECODE=1 && \
    if [[ \"$0\" != \"\" ]]; then \
        exec $0 $@ ; \
    else \
        echo ====== Syntax check ====== && \
        python /secrules_parsing/secrules_parser.py -c -f /etc/modsecurity/crs/rules/*.conf  && \
        echo '' && \
        echo ====== Formatting check ====== && \
        cd /etc/modsecurity/crs/ && \
        py.test -vs ./util/integration/format_tests.py && \
        echo '' && \
        echo ====== CRS regressions tests using FTW  ====== && \
        cd /etc/modsecurity/crs/ && \
        py.test -vs util/regression-tests/CRS_Tests.py --rule=util/regression-tests/tests/test.yaml && \
        py.test -vs util/regression-tests/CRS_Tests.py --ruledir_recurse=util/regression-tests/tests/ ; \
    fi \
"]
CMD [""]

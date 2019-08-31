#!/bin/bash
#
# Script to post a payload against a local webserver at each paranoia level
#
# Note: Webserver has to be prepared to take desired PL as Request Header "PL"
# Check the access log format at https://www.netnea.com/cms/apache-tutorial-5_extending-access-log/
#
# Path to CRS rule set and local files
CRS="/usr/share/modsecurity-crs/rules/"
accesslog="/apache/logs/access.log"
errorlog="/apache/logs/error.log"

# URL of web server
URL="localhost:40080"

# Rules per Paranoia level
# Paranoia level 1 rules, rule 012 is the phase 2 rule delimiter of the start of PL1
# Paranoia level 1 rules, rule 013 is the phase 1 rule delimiter of the finish of PL1
PL1=$(awk "/012,phase:2/,/013,phase:1/" $CRS/*.conf |egrep -v "(012|013),phase" |egrep -o "id:[0-9]+" |sed -r 's,id:([0-9]+),\1\\,' |tr -t '\n' '\|' |sed -r 's,\\\|$,,')

# Paranoia level 2 rules, rule 014 is the phase 2 rule delimiter of the start of PL2
# Paranoia level 2 rules, rule 015 is the phase 1 rule delimiter of the finish of PL2
PL2=$(awk "/014,phase:2/,/015,phase:1/" $CRS/*.conf |egrep -v "(014|015),phase" |egrep -o "id:[0-9]+" |sed -r 's,id:([0-9]+),\1\\,' |tr -t '\n' '\|' |sed -r 's,\\\|$,,')

# Paranoia level 3 rules, rule 016 is the phase 2 rule delimiter of the start of PL3
# Paranoia level 3 rules, rule 017 is the phase 1 rule delimiter of the finish of PL3
PL3=$(awk "/016,phase:2/,/017,phase:1/" $CRS/*.conf |egrep -v "(016|017),phase" |egrep -o "id:[0-9]+" |sed -r 's,id:([0-9]+),\1\\,' |tr -t '\n' '\|' |sed -r 's,\\\|$,,')

# Paranoia level 4 rules, rule 018 is the phase 2 rule delimiter of the start of PL4
# Paranoia level 4 rules, "Paranoia Levels Finished" delimiter of the finish of PL4
PL4=$(awk "/018,phase:2/,/Paranoia Levels Finished/" $CRS/*.conf |egrep -v "018,phase" |egrep -o "id:[0-9]+" |sed -r 's,id:([0-9]+),\1\\,' |tr -t '\n' '\|' |sed -r 's,\\\|$,,')

if [ ! -z "$1" ]; then
        PAYLOAD="$1"
else
        echo "Please submit payload as parameter. This is fatal. Aborting."
        exit 1
fi

echo "Sending the following payload at multiple paranoia levels: $PAYLOAD"
echo

for PL in 1 2 3 4; do 
        echo "--- Paranoia Level $PL ---" 
        echo
        if [ -f "$PAYLOAD" ]; then
                curl $URL --data-binary "@$PAYLOAD" -H "PL: $PL" -o /dev/null -s
        else
                curl $URL -d "$PAYLOAD" -H "PL: $PL" -o /dev/null -s
        fi 
        grep $(tail -1 $accesslog | cut -d\" -f11 | cut -b2-26) $errorlog | sed -e "s/.*\[id \"//" -e "s/\(......\).*\[msg \"/\1 /" -e "s/\"\].*//" -e "s/(Total .*/(Total ...) .../" -e "s/Incoming and Outgoing Score: [0-9]* [0-9]*/Incoming and Outgoing Score: .../" | sed -e "s/$PL1/& PL1/" -e "s/$PL2/& PL2/" -e "s/$PL3/& PL3/ "-e "s/$PL4/& PL4/" | sort -k2
        echo
        echo -n "Total Incoming Score: "
        tail -1 $accesslog | cut -d\" -f11 | cut -d\  -f14 | tr "-" "0" 
        echo
done

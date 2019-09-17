#!/bin/bash
#
# Script to post a payload against a local webserver at each paranoia level
#
# Note: Webserver has to be prepared to take desired PL as Request Header "PL"

# Warning: Setting the paranoia level using a header without proper authentication and authorization
# is extremely dangerous, and is not recommended for production

# Check the access log format at https://www.netnea.com/cms/apache-tutorial-5_extending-access-log/
# This script assumes %{ModSecAnomalyScoreIn}e is the last access log column
# For better results use the collaborative mode and set the SecDefaultAction to 'pass'
# 
# The anomaly score envvar can be set as follows:
# SecAction "id:90101,phase:5,pass,nolog,setenv:ModSecAnomalyScoreIn=%{TX.anomaly_score}"

# Path to CRS rule set and local files
CRS="/usr/share/modsecurity-crs/rules"
accesslog="/apache/logs/access.log"
errorlog="/apache/logs/error.log"
URL="localhost:40080"
protocol="http"
while [[ $# > 0 ]]
do
    case "$1" in
        -c|--crs)
            CRS="$2"
            shift
            ;;
        -a|--access)
            accesslog="$2"
            shift
            ;;
        -e|--error)
            errorlog="$2"
            shift
            ;;
        -u|--url)
            URL="$2"
            shift
            ;;
        -r|--resolve)
            resolve="$2"
            resolve="--resolve $resolve"
            shift
            ;;
        --protocol)
            protocol="$2"
            shift
            ;;
        --payload)
            PAYLOAD="$2"
            shift
            ;;
        -h|--help)
            echo "Usage:"
            echo " --access \"/apache/logs/access.log\""
            echo " --error \"/apache/logs/error.log\""
            echo " --url \"localhost:40080\""
            echo " --resolve \"someservername:40080:localhost\""
            echo " --protocol \"https\""
            echo " --payload \"/tmp/payload\""
            echo " --help"
            exit 1
            ;;
    esac
    shift
done
	    echo "Using CRS: $CRS"
	    echo "Using accesslog: $accesslog"
	    echo "Using errorlog: $errorlog"
	    echo "Using URL: $URL"
	    echo "Using protocol: $protocol"

if [ -z "${PAYLOAD+x}" ]; then
    echo "Please submit valid payload file as parameter. This is fatal. Aborting."
    $0 -h
    echo "Examples:"
    echo "  ./send-payload-pls.sh -a /logs/test/access.log -e /logs/test/error.log -u test.test.test.com:6443 --protocol https --payload /tmp/payload --resolve test.test.test.com:6443:192.168.0.128"
    echo "  ./send-payload-pls.sh -a /logs/test/access.log -e /logs/test/error.log -u test.test.test.com:6443 --protocol https --payload 'or 1=1;--' --resolve test.test.test.com:6443:192.168.0.128"
    exit 1
fi

# URL of web server

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

echo "Sending the following payload at multiple paranoia levels: $PAYLOAD"
echo

for PL in 1 2 3 4; do 
        echo "--- Paranoia Level $PL ---" 
        echo
        if [ -f "$PAYLOAD" ]; then
            curl $protocol://$URL $resolve -k --data-binary "@$PAYLOAD" -H "PL: $PL" -o /dev/null -s
        else
            curl $protocol://$URL $resolve -k -d "$PAYLOAD" -H "PL: $PL" -o /dev/null -s
        fi
        # Here are three ways to get the transaction unique id, the first one is follini format, second is spartan format,
        # and the third one tries to guess which is the unique id using a regular expression, the first two require specific format
        # the third one may cause false positives
        #uniq_id=$(tail -1 $accesslog | cut -d\" -f11 | cut -b2-26)
        #uniq_id=$(tail -1 $accesslog | awk '{print $21}')
        uniq_id=$(tail -1 $accesslog | egrep -o '[a-zA-Z0-9]{26,28}')
        echo "Tracking unique id: $uniq_id"

        grep $uniq_id $errorlog | sed -e "s/.*\[id \"//" -e "s/\(......\).*\[msg \"/\1 /" -e "s/\"\].*//" -e "s/(Total .*/(Total ...) .../" -e "s/Incoming and Outgoing Score: [0-9]* [0-9]*/Incoming and Outgoing Score: .../" | sed -e "s/$PL1/& PL1/" -e "s/$PL2/& PL2/" -e "s/$PL3/& PL3/ " -e "s/$PL4/& PL4/" | sort -k2 | sed -r "s/^([0-9]+)$/\1 FOREIGN RULE NOT IN CRS/"
        echo
        echo -n "Total Incoming Score: "
        # Here are two ways to get the transaction anomaly score, the first one is follini format, second is spartan format
        #tail -1 $accesslog | cut -d\" -f11 | cut -d\  -f14 | tr "-" "0"
        tail -1 $accesslog | awk '{print $NF}' | tr "-" "0"
        echo
done

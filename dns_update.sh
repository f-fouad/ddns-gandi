#!/bin/bash
APIKEY=
DOMAIN=
SUBDOMAIN=

#TARGET=google.com
TARGET="8.8.8.8"
LIMIT=100
COUNT=0
SLEEPTIME=2

while [ $COUNT -lt $LIMIT ]; do
    COUNT=$(($COUNT +1))
    ping -c 1 $TARGET &> /dev/null
    if [ $? -eq 0 ]; then
            STATUT="Online";
            break;
    fi
    sleep $SLEEPTIME
done

if [ $STATUT = "Online"]; then

    #IP=`resolveip -s ddns.domain.com`
    IP=$(dig @resolver1.opendns.com A myip.opendns.com +short)
    oldIP=$(resolveip -s $SUBDOMAIN.$DOMAIN)
    #oldIP=$(dig $SUBDOMAIN.$DOMAIN +short)

    if [ "$IP" = "$oldIP" ]; then
        echo "[OK] DNS up to date."
    else
        message=$(curl -X PUT -H "Content-Type: application/json" \
        -H "X-Api-Key: $APIKEY" \
        -d '{"rrset_ttl": 300, "rrset_values":["'$IP'"]}' \
        https://dns.api.gandi.net/api/v5/domains/$DOMAIN/records/$SUBDOMAIN/A)

        #message='{"message": "DNS Record Created"}'
        isOK=$(echo "$message" | cut -d'"' -f4)

        if [ "$isOK" = "DNS Record Created" ]; then
            echo "[UPDATED] Record changed from $oldIP to $IP"
        else
            echo "[ERROR] $message"
        fi
    fi
else
    echo "[ERROR] Not Online."
fi

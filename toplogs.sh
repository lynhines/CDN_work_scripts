#!/bin/bash

printf "Assumes standard apache access log format:\n\n"
echo "ip.address - - [date.timestamp] \"request\" httpcode content.length \"referrer\" \"user.agent\"\n\n"

apacheRx='^(\S*)\s(\S*)\s(\S*)\s(\[(\d{2})\/([a-zA-Z]{3})\/(\d{4}):(\d{2}):(\d{2}):(\d{2})\s((\+|\-)\d{4})\])\s"((\S*)\s[^"]*)"\s([0-9]{3})\s([0-9]*)\s"([^"]*)"\s"([^"]*)(.*)"(.*)$'

if [ $# -eq 0 ]; then
    echo "Usage (for top 10):"
    echo "toplogs.sh filename 10"
    exit 1
fi

if [ -z "$2" ]
then
	total=10
else
	total=$2
fi

printHeader () {

        printf "\n-------------------\n"
        printf "$1"
        printf "\n-------------------\n\n"

        return 1
}

printHeader 'Response Codes'
perl -n -e '/'"$apacheRx"'/ && print $15."\r\n"' $1 | sort | uniq -c | sort -nr

printHeader 'Request Methods'
perl -n -e '/'"$apacheRx"'/ && print $14."\r\n"' $1 | sort | uniq -c | sort -nr

printHeader 'Top '"$total"' Requests'
perl -n -e '/'"$apacheRx"'/ && print $13."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

printHeader 'Top '"$total"' User Agents'
perl -n -e '/'"$apacheRx"'/ && print $18."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

printHeader 'Top '"$total"' Referrers'
perl -n -e '/'"$apacheRx"'/ && print $17."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

printHeader 'Top '"$total"' IPs'
perl -n -e '/'"$apacheRx"'/ && print $1."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

printHeader 'Top '"$total"' Days'
perl -n -e '/'"$apacheRx"'/ && print $5."/".$6."/".$7."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

printHeader 'Top '"$total"' Hours'
perl -n -e '/'"$apacheRx"'/ && print $5."/".$6."/".$7." ".$8."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

printHeader 'Top '"$total"' Minutes'
perl -n -e '/'"$apacheRx"'/ && print $5."/".$6."/".$7." ".$8.":".$9."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

printHeader 'Top '"$total"' Seconds'
perl -n -e '/'"$apacheRx"'/ && print $5."/".$6."/".$7." ".$8.":".$9.":".$10."\r\n"' $1 | sort | uniq -c | sort -nr | head -n $total

exit 0

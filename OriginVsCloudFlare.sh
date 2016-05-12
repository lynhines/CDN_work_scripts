#!/bin/bash
#11 July 2013
#Simple script to compare speeds between connecting diretly to origin IP vs DNS (Assumes DNS directs request CDN)

CURL="/usr/bin/curl"
AWK="/usr/bin/awk"

printf "Please pass the url you want to measure:"
read URL
printf "Please pass your origin IP address: "
read ORIGINIP

#printf "\n"
#printf "Request originating from: "
#$CURL canhazip.com
#printf "\n"

printf "CloudFlare Headers:\n"
$CURL -s --include --url $URL |grep -a CF-
#Make request for resource via DNS and report back CloudFlare headers

printf "Origin Cache Headers:\n"
#$CURL -s --include --url $URL |grep -ai cache-control
$CURL -s -I --include --url $URL 

printf "\n"

CFRESULT=`$CURL -o /dev/null -s -w %{time_connect}:%{time_starttransfer}:%{time_total} --url $URL`
#Make request for resource via DNS and store metrics

ORIGINRESULT=`$CURL -o /dev/null -s -H "Host: $URL" -w %{time_connect}:%{time_starttransfer}:%{time_total} --url $ORIGINIP`
#Make request for resource directly via IP and store metrics

printf "\t\tTime_Connect\tTime_StartTransfer\tTime_Total\n"
printf "CDN:"
echo $CFRESULT | $AWK -F: '{ print "\t"$1"\t\t"$2"\t\t\t"$3}'
printf "Origin:"
echo $ORIGINRESULT | $AWK -F: '{ print "\t\t"$1"\t\t"$2"\t\t\t"$3}'

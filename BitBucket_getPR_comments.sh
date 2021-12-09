#!/bin/bash
set -e

# README
# This script is to get all Pull request comments of particular repository between a certain time window.
# Usage:
# Update startdate, enddate & reponame and save the file
# Goto the shell prompt and run below command
# sh <ThisFileName>
# After execution, open 'report.txt' to get your report
# Please note timezone for start & end date is set to UTC
# Date format is YYYY-MM-DD

startdate="2021-11-25"
enddate="2021-12-1"
 
reponame="XXXXXX"
 

bitbucketWorkspace="XXXXXXXX"
bitBucketKey='XXXXXXXXX'
bitBucketSecret='XXXXXXXXXX'

#Get access token from client consumer.
token=$(curl -X POST -u "${bitBucketKey}:${bitBucketSecret}"   https://bitbucket.org/site/oauth2/access_token   -d grant_type=client_credentials |jq -r '.access_token')
# to making report empty
cat /dev/null > report.txt
#Get PR Ids for each repo
# Loop for pagination till page 100 if exist
for pageNo in {1..100}
do
curl  "https://api.bitbucket.org/2.0/repositories/${bitbucketWorkspace}/${reponame}/pullrequests?access_token=${token}&q=updated_on+%3E+${startdate}+and+updated_on+%3C+${enddate}&pagelen=50&page=${pageNo}" 2> /dev/null |jq -r '.values[].id' > ids.txt
#&q=updated_on+%3E+${startdate}+and+updated_on+%3C+${enddate}&pagelen=50&page=1
#Get comments for each updated PR
echo "\n\n---${startdate} to ${enddate}---Page No ${pageNo}"
echo ${reponame}

while read -r ids ;
do
echo "Fetching the report .."

#echo -n "PR Number $ids" >> report.txt
#echo  "demy" >> report.txt
curl  "https://api.bitbucket.org/2.0/repositories/${bitbucketWorkspace}/${reponame}/pullrequests/${ids}/comments?access_token=${token}" 2> /dev/null   | jq -r '.values[].content.raw' > tempreport.txt

# Skip report entry if no comments
prComment="$(cat tempreport.txt | wc -l)"
if [ "${prComment}" -gt 0 ]; then
echo "PR Number $ids $(cat tempreport.txt)" >> report.txt
echo "--------------------------------------------------" >> report.txt
fi

done < ids.txt

lastPageCount="$(cat ids.txt | wc -l)"
echo ${lastPageCount}
# exit from look if last page was not full
if [ "${lastPageCount}" -lt 50 ]; then
  break
fi
done
# Find the final report
cat report.txt

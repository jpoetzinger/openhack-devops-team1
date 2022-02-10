#!/bin/bash

declare -i duration=10
declare hasUrl=""
declare endpoint
declare -i status200count=0

# Paste the webapp site you want to monitor
endpoint=$1


for i in {1..12}
do
 # echo 'in check'
 # result='healthcheck $endpoint' 
  result=$(curl -i $endpoint 2>/dev/null | grep HTTP/2)
  declare status
  if [[ -z $result ]]; then 
    status="N/A"
    echo "Site not found"
  else
    status=${result:7:3}
    timestamp=$(date "+%Y%m%d-%H%M%S")
    if [[ -z $hasUrl ]]; then
      echo "$timestamp | $status "
    else
      echo "$timestamp | $status | $endpoint " 
    fi 
    echo $status
    if [ $status -eq 200 ]; then
      ((status200count=status200count + 1))

      if [ $status200count -gt 5 ]; then
          break
      fi
    fi

    sleep $duration
  fi
done

if [ $status200count -gt 5 ]; then
  echo "API UP"
  # APISTATUS is a pipeline variable
  APISTATUS="Up"
  echo ::set-env name=APIPRODSTATUS::true
else
  echo "API DOWN"
  APISTATUS="Down"
  echo ::set-env name=APIPRODSTATUS::false
  exit 1;
fi
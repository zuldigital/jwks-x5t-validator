#!/bin/bash

JKU="$1"

echo "Validating x5t from JWKS at: $JKU"
echo

list=`curl -s $1 | jq --raw-output '.keys[] | ("\(.kid) \(.x5t) \(.x5c[0])")'`

while IFS= read -r line; do
  kid=`echo $line | awk '{print $1}'`
  x5t=`echo $line | awk '{print $2}'`
  x5c=`echo $line | awk '{print $3}'`

  computed_x5t=`echo $x5c|base64 -d|openssl sha1 -binary|base64|tr -d '='|tr '/+' '_-'`

  echo "  kid: $kid"
  echo "  x5t: $x5t"
  echo
  if [ "$x5t" = "$computed_x5t" ]; then
  	echo "[SUCCESS] x5t matches computed x5t"
  else
	echo "[FAIL] => computed x5t: $computed_x5t"
  fi
  echo

done <<< "$list"
#!/bin/bash

JKU="$1"

echo "Validating x5t from JWKS at: $JKU"
echo

# retrieve all keys (one kid/x5t/x5c per line) from JWKS
list=`curl -s $1 | jq --raw-output '.keys[] | ("\(.kid) \(.x5t) \(.x5c[0])")'`

while IFS= read -r line; do
  kid=`echo $line | awk '{print $1}'`
  x5t=`echo $line | awk '{print $2}'`
  x5c=`echo $line | awk '{print $3}'`

  # for each line compute x5t by following these steps:
  #  1. "echo $x5c|base64 -d" -> base64 decode x5c certificate
  #  2. "openssl sha1 -binary" -> compute certificate's SHA-1 in binary format
  #  3. "base64" -> base64 encode it
  #  4. "tr -d '='|tr '/+' '_-'" -> convert from base64 to base64url as demanded by RFC7515: https://tools.ietf.org/html/rfc7515#page-12
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

#!/bin/bash

# ******************************************************************************
#  Licensed Materials - Property of IBM
#  © Copyright IBM Corporation 2019. All Rights Reserved.
#
#  Note to U.S. Government Users Restricted Rights:
#  Use, duplication or disclosure restricted by GSA ADP Schedule
#  Contract with IBM Corp.
# ******************************************************************************

# Watson IoT Platform
WIOTP_ORG=""
WIOTP_DEVICE_TOKEN=""
WIOTP_DEVICE_TYPE=""
WIOTP_DEVICE_ID=""
# Maximo Worker Insights
MWI_HOST="" # defaults to prod host
MWI_TENANT=""
MWI_ORG_KEY=""
MWI_USER_ID=""
# LogDNA (optional)
LOG_TO_CLOUD=true
LOG_DNA_KEY=""
# **************************** EDIT END ******************************** #

if [ -z "$WIOTP_ORG" ]; then      
  echo "Provide the ORG of WIOTP, followed by [ENTER]:"
  read WIOTP_ORG
fi
if [ -z "$WIOTP_DEVICE_TYPE" ]; then      
  echo "Provide the WIOTP Device TYPE of your device, followed by [ENTER]:"
  read WIOTP_DEVICE_TYPE
fi
if [ -z "$WIOTP_DEVICE_ID" ]; then      
  echo "Provide the WIOTP Device ID of your device, followed by [ENTER]:"
  read WIOTP_DEVICE_ID
fi
if [ -z "$WIOTP_DEVICE_TOKEN" ]; then      
  echo "Provide the WIOTP Device TOKEN of your device, followed by [ENTER]:"
  read WIOTP_DEVICE_TOKEN
fi
if [ -z "$MWI_TENANT" ]; then
  echo "Provide the MWI Tenant ID, followed by [ENTER]:"
  read MWI_TENANT
fi
if [ -z "$MWI_ORG_KEY" ]; then
  echo "Provide the MWI Context KEY, followed by [ENTER]:"
  read MWI_ORG_KEY
fi
if [ -z "$MWI_USER_ID" ]; then
  echo "Provide the MWI User ID, followed by [ENTER]:"
  read MWI_USER_ID
fi

HZN_API_LISTEN=$(cat /etc/horizon/anax.json | jq -r '.Edge.APIListen' | cut -d ":" -f 2)
HZN_ORG_ID="${HZN_ORG_ID:-IBM-WorkerInsight}"
SERVICE_URL="${SERVICE_URL:-https://internetofthings.ibmcloud.com/service/iot-gateway-client}"
VERSION_RANGE="${VERSION_RANGE:-[0.0.0,INFINITY)}"
HZN_API_LISTEN="${HZN_API_LISTEN:-8888}"
HORIZON_URL="http://127.0.0.1:${HZN_API_LISTEN}"
# Watson IoT Platform
WIOTP_CLIENT_ID="g:${WIOTP_ORG}:${WIOTP_DEVICE_TYPE}:${WIOTP_DEVICE_ID}"
WIOTP_DEVICE_PW="${WIOTP_DEVICE_TOKEN}"
WIOTP_SOLUTION=""
# Maximo Worker Insights
MWI_TENANT_ID="${MWI_TENANT}"
TENANT_ID="${MWI_TENANT}"
# Edge
INPUT_FILE="$(pwd)/input.json"

export WIOTP_ORG
export WIOTP_REGION
export WIOTP_DEVICE_TYPE
export WIOTP_DEVICE_ID
export WIOTP_CLIENT_ID
export WIOTP_DEVICE_TOKEN
export WIOTP_DEVICE_PW
export WIOTP_SOLUTION

export HZN_ORG_ID
export SERVICE_URL
export VERSION_RANGE

export INPUT_FILE

export MWI_HOST
export MWI_TENANT
export MWI_TENANT_ID
export TENANT_ID
export MWI_CONTEXT
export MWI_USER_ID
export HORIZON_URL

cat <<EOF > /etc/wiotp-edge/routing.json
[
 {
   "rule_id": 1,
   "matching_filter": "send-to-cloud/iot-2/#",
   "forward_skip_levels": 1,
   "destination": "CLOUD"
 },
 {
 "rule_id": 2,
 "matching_filter": "iot-2/type/+/id/+/evt/status/fmt/json",
 "destination": "CLOUD"
 },
 {
 "rule_id": 3,
 "matching_filter": "iotdevice-1/type/+/id/+/add/diag/log",
 "destination": "CLOUD"
 },
 {
 "rule_id": 4,
 "matching_filter": "iot-2/type/+/id/+/evt/hazard/fmt/json",
 "destination": "CLOUD"
 },
 {
 "rule_id": 5,
 "matching_filter": "iot-2/type/+/id/+/evt/+/fmt/json",
 "destination": "LOCAL"
 }]
EOF


cat <<EOT >> "${INPUT_FILE}"
  {
      "services": [
          {
              "org": "$HZN_ORG_ID",
              "url": "$SERVICE_URL",
              "versionRange": "$VERSION_RANGE",
              "variables": {
                "MWI_TENANT_ID": "$MWI_TENANT_ID",
                "TENANT_ID": "$MWI_TENANT_ID",
                "MWI_HOST":"$MWI_HOST",
                "LOG_DNA_KEY": "$LOG_DNA_KEY",
                "LOG_TO_CLOUD": "$LOG_TO_CLOUD",
                "WIOTP_DEVICE_TYPE": "$WIOTP_DEVICE_TYPE",
                "WIOTP_DEVICE_ID": "$WIOTP_DEVICE_ID",
                "WIOTP_CLIENT_ID": "$WIOTP_CLIENT_ID",
                "WIOTP_DEVICE_PW": "$WIOTP_DEVICE_PW",
                "WIOTP_ORG": "$WIOTP_ORG",
                "MWI_USER_ID": "$MWI_USER_ID",
                "MWI_ORG_KEY": "$MWI_CONTEXT"
              }
          }
      ]
  }
EOT
}

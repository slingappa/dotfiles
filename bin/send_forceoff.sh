#!/usr/bin/env bash
set -euo pipefail

BMC_HOSTPORT="${BMC_HOSTPORT:-localhost:2443}"
BMC_USER="${BMC_USER:-root}"
: "${BMC_PASS:?Set BMC_PASS}"

token="$(
  curl -k -H "Content-Type: application/json" -X POST "https://${BMC_HOSTPORT}/login" \
    -d "{\"username\":\"${BMC_USER}\",\"password\":\"${BMC_PASS}\"}" \
    | grep token | awk '{print $2;}' | tr -d '"'
)"

curl -k -H "X-Auth-Token: ${token}" -X GET "https://${BMC_HOSTPORT}/redfish/v1/Managers" -v
curl -k -H "X-Auth-Token: ${token}" -X GET "https://${BMC_HOSTPORT}/redfish/v1/Systems" -v
curl -k -H "X-Auth-Token: ${token}" -X GET "https://${BMC_HOSTPORT}/redfish/v1/Chassis" -v
curl -k -H "X-Auth-Token: ${token}" -X GET "https://${BMC_HOSTPORT}/redfish/v1/Managers/bmc" -v
curl -k -H "X-Auth-Token: ${token}" -X GET "https://${BMC_HOSTPORT}/redfish/v1/Managers/bmc/EthernetInterfaces" -v

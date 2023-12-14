#!/bin/bash
# From https://docs.ci.openshift.org/docs/how-tos/interact-with-running-jobs/
JSON=$(mktemp)
AZURE=/home/medic/Work/Projekty/kata/tmp/azure.json
oc -n kube-system get secret azure-credentials -o json > $JSON

echo "{" > "$AZURE"
echo "  \"azure_client_id\": \"$(cat $JSON       | jq .data.azure_client_id|sed 's/\"//g'|base64 -d)\"," >> "$AZURE"
echo "  \"azure_client_secret\": \"$(cat $JSON   | jq .data.azure_client_secret|sed 's/\"//g'|base64 -d)\"," >> "$AZURE"
echo "  \"azure_region\": \"$(cat $JSON          | jq .data.azure_region|sed 's/\"//g'|base64 -d)\"," >> "$AZURE"
echo "  \"azure_resource_prefix\": \"$(cat $JSON | jq .data.azure_resource_prefix|sed 's/\"//g'|base64 -d)\"," >> "$AZURE"
echo "  \"azure_resourcegroup\": \"$(cat $JSON   | jq .data.azure_resourcegroup|sed 's/\"//g'|base64 -d)\"," >> "$AZURE"
echo "  \"azure_subscription_id\": \"$(cat $JSON | jq .data.azure_subscription_id|sed 's/\"//g'|base64 -d)\"," >> "$AZURE"
echo "  \"azure_tenant_id\": \"$(cat $JSON       | jq .data.azure_tenant_id|sed 's/\"//g'|base64 -d)\"" >> "$AZURE"
echo "}" >> "$AZURE"
rm "$JSON"

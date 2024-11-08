#!/bin/bash

echo "INFO: $0 start"
echo "INFO: loading .env file"
source .env

# Set file paths
DEST_PATH="./etc"
NETWORK_FILE="./storage/generateconfig/network.yml"

echo "INFO: Create directories for all node types"
for NODE_TYPE in node-1 filenode coordinator consensusnode; do
    mkdir -p "${DEST_PATH}/any-sync-${NODE_TYPE}"
done

echo "INFO: Create directory for aws credentials"
mkdir -p "${DEST_PATH}/.aws"

echo "INFO: Configure external listen host"
python ./generateconfig/setListenIp.py "./storage/generateconfig/nodes.yml" "./storage/generateconfig/nodesProcessed.yml"

echo "INFO: Create config for clients"
cp "./storage/generateconfig/nodesProcessed.yml" "${DEST_PATH}/client.yml"

echo "INFO: Generate network file"
yq eval '. as $item | {"network": $item}' --indent 2 ./storage/generateconfig/nodesProcessed.yml > "${NETWORK_FILE}"

echo "INFO: Generate config files for 3 nodes"
cat \
    "${NETWORK_FILE}" \
    generateconfig/templates/common.yml \
    storage/generateconfig/account0.yml \
    generateconfig/templates/node-1.yml \
    > "${DEST_PATH}/any-sync-node-1/config.yml"

echo "INFO: Generate config files for coordinator"
cat "${NETWORK_FILE}" generateconfig/templates/common.yml storage/generateconfig/account1.yml generateconfig/templates/coordinator.yml \
    > ${DEST_PATH}/any-sync-coordinator/config.yml
echo "INFO: Generate config files for filenode"
cat "${NETWORK_FILE}" generateconfig/templates/common.yml storage/generateconfig/account2.yml generateconfig/templates/filenode.yml \
    > ${DEST_PATH}/any-sync-filenode/config.yml
echo "INFO: Generate config files for consensusnode"
cat "${NETWORK_FILE}" generateconfig/templates/common.yml storage/generateconfig/account3.yml generateconfig/templates/consensusnode.yml \
    > ${DEST_PATH}/any-sync-consensusnode/config.yml

echo "INFO: Copy network file to coordinator directory"
cp "storage/generateconfig/nodesProcessed.yml" "${DEST_PATH}/any-sync-coordinator/network.yml"

echo "INFO: Copy aws credentials config"
cp "generateconfig/templates/aws-credentials" "${DEST_PATH}/.aws/credentials"

echo "INFO: Replace variables from .env file"
for PLACEHOLDER in $( perl -ne 'print "$1\n" if /^([A-z0-9_-]+)=/' .env ); do
    perl -i -pe "s|%${PLACEHOLDER}%|${!PLACEHOLDER}|g" \
        "${DEST_PATH}/"/.aws/credentials \
        "${NETWORK_FILE}" \
        "${DEST_PATH}/"/*/*.yml
done

echo "INFO: fix indent in yml files"
for FILE in $( find ${DEST_PATH}/ -name "*.yml" ); do
    yq --inplace --indent=2 $FILE
done

echo "INFO: $0 done"

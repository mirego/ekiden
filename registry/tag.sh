#!/bin/bash
# Allow to add a tag to an OCI image without having to pull it first

REGISTRY_NAME="https://10.1.3.132"
REPOSITORY=mirego/runner
USERNAME=username
PASSWORD=password

TAG_OLD=latest
TAG_NEW=latest
read -pr "Old tag: " TAG_OLD
read -pr "New tag: " TAG_NEW

CONTENT_TYPE="application/vnd.docker.distribution.manifest.v2+json"
HEADER=$(echo "${USERNAME}:${PASSWORD}" | base64)
TOKEN=$(curl -H "Authorization: Basic ${HEADER}" "${REGISTRY_NAME}/v2/token?service=container_registry&scope=*" | jq -r '.token') || {
	echo 'Failed to get token'
	exit 1
}
MANIFEST=$(curl -H "Accept: ${CONTENT_TYPE}" -H "Authorization: Bearer ${TOKEN}" "${REGISTRY_NAME}/v2/${REPOSITORY}/manifests/${TAG_OLD}") || {
	echo 'Failed to get manifest'
	exit 1
}
curl -X PUT -H "Content-Type: ${CONTENT_TYPE}" -H "Authorization: Bearer ${TOKEN}" -d "${MANIFEST}" "${REGISTRY_NAME}/v2/${REPOSITORY}/manifests/${TAG_NEW}" || {
	echo 'Failed to create tag'
	exit 1
}

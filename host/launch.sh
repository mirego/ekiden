#!/bin/bash

GITHUB_API_TOKEN=
GITHUB_REGISTRATION_ENDPOINT=

VM_USERNAME=runner

RUNNER_LABELS=self-hosted,M1
RUNNER_URL=
RUNNER_NAME=Runner

REGISTRY_URL=
REGISTRY_USERNAME=
REGISTRY_PASSWORD=
REGISTRY_IMAGE_NAME=runner

LOGFILE=runner.log

function log_output {
	echo "$(date "+%Y/%m/%d %H:%M:%S") $1"
	echo "$(date "+%Y/%m/%d %H:%M:%S") [${RUN_ID:-PREPARING}] $1" >>$LOGFILE
}

function stream_output {
	while read -r line; do
		log_output "$line"
	done
}

# Load .env file
if [ -f .env ]; then
	# shellcheck disable=SC2046
	export $(xargs <.env)
fi

# Configure Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Show a shutdown message when closing the script
trap "log_output \"[HOST] 🚦 Stopping runner script\"; exit 1" SIGINT

# Select image
if [ -n "${REGISTRY_URL}" ]; then
	REGISTRY_PATH="$REGISTRY_URL/$REGISTRY_IMAGE_NAME"
else
	REGISTRY_PATH="$REGISTRY_IMAGE_NAME"
fi

# Main loop
while :; do
	RUN_ID="$RANDOM$RANDOM"

	log_output "[HOST] 🎫 Creating registration token"
	REGISTRATION_TOKEN=$(curl -s -XPOST -H "Authorization: bearer $GITHUB_API_TOKEN" -H "Accept: application/vnd.github.v3+json" "$GITHUB_REGISTRATION_ENDPOINT" | grep "token" | sed "s/..\"token\":.\"//" | sed "s/\",$//")

	log_output "[HOST] 💻 Launching macOS VM"
	INSTANCE_NAME=runner_"$RUNNER_NAME"_"$RUN_ID"
	TART_REGISTRY_USERNAME=$REGISTRY_USERNAME TART_REGISTRY_PASSWORD=$REGISTRY_PASSWORD tart clone $REGISTRY_PATH $INSTANCE_NAME
	trap 'log_output "[HOST] 🪓 Killing the VM"; tart delete $INSTANCE_NAME; log_output "[HOST] 🚦 Stopping runner script"; exit 1' SIGINT
	tart run --no-graphics $INSTANCE_NAME >/dev/null 2>&1 &

	log_output "[HOST] 💤 Waiting for VM to boot"
	IP_ADDRESS=$(tart ip $INSTANCE_NAME)
	until [[ "$IP_ADDRESS" =~ ^([0-9]+\.){3}[0-9]+$ ]]; do
		IP_ADDRESS=$(tart ip $INSTANCE_NAME)
		sleep 1
	done

	log_output "[HOST] 💤 Waiting for SSH to be available on VM"
	until [ "$(ssh -q -o ConnectTimeout=1 -o StrictHostKeyChecking=no -oBatchMode=yes "$VM_USERNAME@$IP_ADDRESS" pwd)" ]; do
		sleep 1
	done

	log_output "[HOST] 🔨 Configuring runner on VM"
	ssh -q "$VM_USERNAME@$IP_ADDRESS" "./actions-runner/config.sh --url $RUNNER_URL --token $REGISTRATION_TOKEN --ephemeral --name $RUNNER_NAME --labels $RUNNER_LABELS --unattended --replace" >/dev/null

	log_output "[HOST] 🏃 Starting runner on VM"
	ssh -q "$VM_USERNAME@$IP_ADDRESS" "source ~/.zprofile && ./actions-runner/run.sh" 2>&1 | sed -nru 's/^(.+)$/[GUEST] 📀 \1/p' | stream_output

	log_output "[HOST] ✋ Stop the VM"
	tart stop "$INSTANCE_NAME"

	log_output "[HOST] 🧹 Cleanup the VM"
	tart delete "$INSTANCE_NAME"

	RUN_ID=""
	trap 'log_output "[HOST] 🚦 Stopping runner script"; exit 1' SIGINT
done

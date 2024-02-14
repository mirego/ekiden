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

SCHEDULE_SHUTDOWN=false

function log_output {
	echo "$(date "+%Y/%m/%d %H:%M:%S") $1"
	echo "$(date "+%Y/%m/%d %H:%M:%S") [${RUN_ID:-PREPARING}] $1" >>$LOGFILE
}

function stream_output {
	while read -r line; do
		log_output "$line"
	done
}

function reload_env {
	if [ -f .env ]; then
		# shellcheck disable=SC2046
		export $(xargs <.env)
	fi
}

function cleanup {
	log_output "[HOST] 🚦 Stopping runner script"
	exit 0
}

function pull_image {
	log_output "[HOST] ⬇️ Downloading from remote registry"
	TART_REGISTRY_USERNAME=$REGISTRY_USERNAME TART_REGISTRY_PASSWORD=$REGISTRY_PASSWORD tart pull "$REGISTRY_PATH"
}

function run_loop {
	RUN_ID="$RANDOM$RANDOM"

	log_output "[HOST] 🎫 Creating registration token"
	REGISTRATION_TOKEN=$(curl -s -XPOST -H "Authorization: bearer $GITHUB_API_TOKEN" -H "Accept: application/vnd.github.v3+json" "$GITHUB_REGISTRATION_ENDPOINT" | grep "token" | sed "s/..\"token\":.\"//" | sed "s/\",$//")

	log_output "[HOST] 💻 Launching macOS VM"
	INSTANCE_NAME=runner_"$RUNNER_NAME"_"$RUN_ID"
	tart clone "$REGISTRY_PATH" "$INSTANCE_NAME"
	trap 'log_output "[HOST] 🪓 Killing the VM"; tart delete $INSTANCE_NAME; cleanup' SIGINT SIGTERM
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
	ssh -q -o StrictHostKeyChecking=no "$VM_USERNAME@$IP_ADDRESS" "./actions-runner/config.sh --url $RUNNER_URL --token $REGISTRATION_TOKEN --ephemeral --name $RUNNER_NAME --labels $RUNNER_LABELS --unattended --replace" >/dev/null

	log_output "[HOST] 🏃 Starting runner on VM"
	ssh -q -o StrictHostKeyChecking=no "$VM_USERNAME@$IP_ADDRESS" "source ~/.zprofile && ./actions-runner/run.sh" 2>&1 | sed -nru 's/^(.+)$/[GUEST] 📀 \1/p' | stream_output

	log_output "[HOST] ✋ Stop the VM"
	tart stop "$INSTANCE_NAME"

	log_output "[HOST] 🧹 Cleanup the VM"
	tart delete "$INSTANCE_NAME"

	RUN_ID=""
	trap cleanup SIGINT SIGTERM
}

# Configure Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Show a shutdown message when closing the script
trap cleanup SIGINT SIGTERM

# Main loop
while :; do
	reload_env

	if [[ "$SCHEDULE_SHUTDOWN" == "true" ]]; then
		log_output "[HOST] ⏰ Scheduled for shutdown"
		cleanup
	fi

	# Select image
	if [ -n "${REGISTRY_URL}" ]; then
		REGISTRY_PATH="$REGISTRY_URL/$REGISTRY_IMAGE_NAME"
	else
		REGISTRY_PATH="$REGISTRY_IMAGE_NAME"
	fi

	if tart list | grep $REGISTRY_PATH; then
		run_loop
	else
		log_output "[HOST] 🔎 Target image not found"
		if [ -n "${REGISTRY_URL}" ]; then
			pull_image
		else
			cleanup
		fi
	fi
done

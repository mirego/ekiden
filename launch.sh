#!/bin/bash
#
# Usage:
# $ ./launch.sh RUNNER_NAME
#

GITHUB_API_TOKEN=<TOKEN>
GITHUB_REGISTRATION_ENDPOINT=https://api.github.com/orgs/mirego/actions/runners/registration-token

IMAGE_NAME=runner
VM_USERNAME=runner
VM_RUNNER_PATH=./actions-runner

RUNNER_LABELS=self-hosted,M1,mirego
RUNNER_URL=https://github.com/mirego
RUNNER_NAME=${1:-Runner}

if [ -f .env ]
then
  export $(cat .env | xargs)
fi

while :
do
  echo "🎫 [HOST] Creating registration token"
  REGISTRATION_TOKEN=$(curl -s -XPOST -H "Authorization: bearer $GITHUB_API_TOKEN" -H "Accept: application/vnd.github.v3+json" $GITHUB_REGISTRATION_ENDPOINT | grep "token" | sed "s/..\"token\":.\"//" | sed "s/\",$//")

  echo "💻 [HOST] Launching macOS VM"
  INSTANCE_NAME=runner_"$RUNNER_NAME"_"$RANDOM"
  trap "echo 'Cannot exit while VM is starting'" SIGINT
  tart clone $IMAGE_NAME $INSTANCE_NAME
  tart run --no-graphics $INSTANCE_NAME &
  trap "tart stop $INSTANCE_NAME; tart delete $INSTANCE_NAME; exit 1" SIGINT

  echo "💤 [HOST] Waiting for VM to boot"
  sleep 1
  IP_ADDRESS=$(tart ip $INSTANCE_NAME)
  until [ "$(ssh -q -o ConnectTimeout=1 -o StrictHostKeyChecking=no $VM_USERNAME@$IP_ADDRESS pwd)" ]
  do
    echo "💤 [HOST] Still waiting for SSH…"
  done

  echo "🛠  [HOST] Configuring runner on VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "$VM_RUNNER_PATH/config.sh --url $RUNNER_URL --token $REGISTRATION_TOKEN --ephemeral --name $RUNNER_NAME --labels $RUNNER_LABELS --unattended --replace" > /dev/null

  echo "🏃 [HOST] Starting runner on VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "$VM_RUNNER_PATH/run.sh" 2>&1 | sed -nr 's/^(.+)$/📀 [GUEST] \1/p'
  
  echo "🪓 [HOST] Sending kill command to VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "sudo halt" > /dev/null 2>&1

  echo "🔌 [HOST] Waiting for the VM to shut down"
  wait $PID
  rm -f $LOG_FILE
  trap - SIGINT
done

#!/bin/bash
#
# Usage:
# $ ./launch.sh RUNNER_NAME
#

GITHUB_API_TOKEN=<TOKEN>
GITHUB_REGISTRATION_ENDPOINT=https://api.github.com/orgs/mirego/actions/runners/registration-token

VM_JSON_FILE=vm.json
VM_USERNAME=runner
VM_RUNNER_PATH=./actions-runner

RUNNER_LABELS=self-hosted,M1,mirego
RUNNER_URL=https://github.com/mirego
RUNNER_NAME=${1:-Runner}

while :
do
  echo "🎫 [HOST] Creating registration token"
  REGISTRATION_TOKEN=$(curl -s -XPOST -H "Authorization: bearer $GITHUB_API_TOKEN" -H "Accept: application/vnd.github.v3+json" $GITHUB_REGISTRATION_ENDPOINT | grep "token" | sed "s/..\"token\":.\"//" | sed "s/\",$//")

  echo "💻 [HOST] Launching macOS VM"
  LOG_FILE=vm_logs_"$RUNNER_NAME"_"$RANDOM"
  macosvm --ephemeral $VM_JSON_FILE > $LOG_FILE 2>&1 & VM_PID=$!
  trap "kill $VM_PID; rm -f $LOG_FILE; exit 1" SIGINT

  echo "💤 [HOST] Waiting for VM to boot"
  while : ; do
    sleep 1
    MAC_ADDRESS=$(cat $LOG_FILE | sed -nr 's/.+network: ether ([a-z0-9:]+).*/\1/p' | sed -r 's/(^|:)0/\1/g')
    [ -z "$MAC_ADDRESS" ] || break
  done

  echo "💤 [HOST] Waiting for network to be available on VM"
  while : ; do
    sleep 1
    IP_ADDRESS=$(arp -a | sed -nr "s/\? \(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\).+$MAC_ADDRESS.+/\1/p")
    [ -z "$IP_ADDRESS" ] || break
  done

  echo "💤 [HOST] Waiting for SSH to be available on VM"
  until [ "$(ssh -q -o ConnectTimeout=1 -o StrictHostKeyChecking=no $VM_USERNAME@$IP_ADDRESS pwd)" ]
  do
    echo "💤 [HOST] Still waiting for SSH…"
  done

  echo "🛠  [HOST] Configuring runner on VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "$VM_RUNNER_PATH/config.sh --url $RUNNER_URL --token $REGISTRATION_TOKEN --ephemeral --name $RUNNER_NAME --labels $RUNNER_LABELS --unattended --replace --disableupdate" > /dev/null

  echo "🏃 [HOST] Starting runner on VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "$VM_RUNNER_PATH/run.sh" 2>&1 | sed -nr 's/^(.+)$/📀 [GUEST] \1/p'
  
  echo "🪓 [HOST] Sending kill command to VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "sudo halt" > /dev/null 2>&1

  echo "🔌 [HOST] Waiting for the VM to shut down"
  wait $PID
  rm -f $LOG_FILE
  trap - SIGINT
done

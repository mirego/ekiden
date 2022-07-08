#!/bin/bash
#
# Usage:
# $ ./launch.sh RUNNER_NAME
#

GITHUB_API_TOKEN=<TOKEN>
GITHUB_REGISTRATION_ENDPOINT=https://api.github.com/orgs/mirego/actions/runners/registration-token

VM_JSON_FILE=vm.json
VM_USERNAME=runner
VM_HOSTNAME=githubrunnervm.local
VM_RUNNER_PATH=./actions-runner

RUNNER_LABELS=self-hosted,M1,mirego
RUNNER_URL=https://github.com/mirego

while :
do
  echo "🎫 [HOST] Creating registration token"
  REGISTRATION_TOKEN=$(curl -s -XPOST -H "Authorization: bearer $GITHUB_API_TOKEN" -H "Accept: application/vnd.github.v3+json" $GITHUB_REGISTRATION_ENDPOINT | grep "token" | sed "s/..\"token\":.\"//" | sed "s/\",$//")

  echo "💻 [HOST] Launching macOS VM"
  macosvm --ephemeral $VM_JSON_FILE > /dev/null 2>&1 & VM_PID=$!
  trap "kill $VM_PID; exit 1" SIGINT

  echo "💤 [HOST] Waiting for SSH to be available on VM"
  until [ "$(ssh -q -o ConnectTimeout=1 $VM_USERNAME@$VM_HOSTNAME pwd)" ]
  do
    echo "💤 [HOST] Still waiting for SSH…"
  done

  echo "🛠  [HOST] Configuring runner on VM"
  ssh -q $VM_USERNAME@$VM_HOSTNAME "$VM_RUNNER_PATH/config.sh --url $RUNNER_URL --token $REGISTRATION_TOKEN --ephemeral --name ${1:-Runner} --labels $RUNNER_LABELS --unattended --replace --disableupdate" > /dev/null

  echo "🏃 [HOST] Starting runner on VM"
  ssh -q $VM_USERNAME@$VM_HOSTNAME "$VM_RUNNER_PATH/run.sh" 2>&1 | sed -nr 's/^(.+)$/📀 [GUEST] \1/p'
  
  echo "🏃 [HOST] Sending kill command to VM"
  ssh -q $VM_USERNAME@$VM_HOSTNAME "sudo halt"

  echo "🔌 [HOST] Waiting for the VM to shut down"
  wait $PID
  trap - SIGINT
done

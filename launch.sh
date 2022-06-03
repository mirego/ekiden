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

RUNNER_LABELS=self-hosted,ARM64,M1,mirego
RUNNER_URL=https://github.com/mirego

while :
do
  trap - SIGINT

  echo "🎫 [HOST] Create registration token"
  REGISTRATION_TOKEN=$(curl -s -XPOST -H "Authorization: bearer $GITHUB_API_TOKEN" -H "Accept: application/vnd.github.v3+json" $GITHUB_REGISTRATION_ENDPOINT | grep "token" | sed "s/..\"token\":.\"//" | sed "s/\",$//")

  echo "💻 [HOST] Launch macOS VM in background"
  ./macosvm --ephemeral $VM_JSON_FILE > /dev/null 2>&1 & VM_PID=$!
  trap "kill $VM_PID; exit 1" SIGINT

  echo "💤 [HOST] Waiting for SSH to be available on VM"
  until [ "$(ssh -q -o ConnectTimeout=1 $VM_USERNAME@$VM_HOSTNAME pwd)" ]
  do
    echo "💤 [HOST] Still waiting for SSH…"
  done

  echo "🏃 [HOST] Start runner on VM"
  ssh $VM_USERNAME@$VM_HOSTNAME "./actions-runner/config.sh --url $RUNNER_URL --token $REGISTRATION_TOKEN --ephemeral --name ${1:-Runner} --labels $RUNNER_LABELS --unattended --replace --disableupdate && ./actions-runner/run.sh && sudo halt"

  echo "🔌 [HOST] Waiting for the VM to shut down"
  wait $PID
done

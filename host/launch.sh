#!/bin/bash

GITHUB_API_TOKEN=
GITHUB_REGISTRATION_ENDPOINT=

VM_USERNAME=runner

RUNNER_LABELS=self-hosted,M1
RUNNER_URL=https://github.com/mirego
RUNNER_NAME=Runner

REGISTRY_URL=
REGISTRY_USERNAME=
REGISTRY_PASSWORD=
REGISTRY_IMAGE_NAME=runner

KEYCHAIN_PASSWORD=

LOGFILE=runner.log

# Save output to a log file
exec > >(tee -ia $LOGFILE)
exec 2>&1

# Load .env file
if [ -f .env ]
then
  export $(cat .env | xargs)
fi

if [ -n "$KEYCHAIN_PASSWORD" ]
then
  echo "[HOST] 🔐 Unlocking the keychain"
  security unlock-keychain -p "$KEYCHAIN_PASSWORD" ~/Library/Keychains/login.keychain-db
fi

echo "[HOST] 📡 Logging into the VM registry"
echo -n "$REGISTRY_PASSWORD" | tart login $REGISTRY_URL --username $REGISTRY_USERNAME --password-stdin

while :
do
  echo "[HOST] 🎫 Creating registration token"
  REGISTRATION_TOKEN=$(curl -s -XPOST -H "Authorization: bearer $GITHUB_API_TOKEN" -H "Accept: application/vnd.github.v3+json" $GITHUB_REGISTRATION_ENDPOINT | grep "token" | sed "s/..\"token\":.\"//" | sed "s/\",$//")

  echo "[HOST] 💻 Launching macOS VM"
  INSTANCE_NAME=runner_"$RUNNER_NAME"_"$RANDOM"
  tart clone $REGISTRY_URL/$REGISTRY_IMAGE_NAME $INSTANCE_NAME
  trap "tart delete $INSTANCE_NAME; exit 1" SIGINT
  tart run --no-graphics $INSTANCE_NAME > /dev/null 2>&1 &

  echo "[HOST] 💤 Waiting for VM to boot"
  IP_ADDRESS=$(tart ip $INSTANCE_NAME)
  until [[ "$IP_ADDRESS" =~ ^([0-9]+\.){3}[0-9]+$ ]]
  do
    IP_ADDRESS=$(tart ip $INSTANCE_NAME)
    sleep 1
  done

  echo "[HOST] 💤 Waiting for SSH to be available on VM"
  until [ "$(ssh -q -o ConnectTimeout=1 -o StrictHostKeyChecking=no -oBatchMode=yes $VM_USERNAME@$IP_ADDRESS pwd)" ]
  do
    sleep 1
  done

  echo "[HOST] 🔨 Configuring runner on VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "./actions-runner/config.sh --url $RUNNER_URL --token $REGISTRATION_TOKEN --ephemeral --name $RUNNER_NAME --labels $RUNNER_LABELS --unattended --replace" > /dev/null

  echo "[HOST] 🏃 Starting runner on VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "source ~/.zprofile && ./actions-runner/run.sh" 2>&1 | sed -nru 's/^(.+)$/[GUEST] 📀 \1/p'
  
  echo "[HOST] 🪓 Sending kill command to VM"
  ssh -q $VM_USERNAME@$IP_ADDRESS "sudo halt" > /dev/null 2>&1

  echo "[HOST] 🔌 Waiting for the VM to shut down"
  wait $PID

  echo "[HOST] 🧹 Cleanup the VM"
  tart delete $INSTANCE_NAME
  trap - SIGINT
done

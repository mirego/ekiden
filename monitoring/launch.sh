#!/bin/bash

# Configure Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Start container runtime
colima start

# Start containers
docker-compose up

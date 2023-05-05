# Guest Configuration

The templates for this projet were adapted from the [cirruslab templates](https://github.com/cirruslabs/macos-image-templates).

## Prerequisite

Make sure you have both `tart` and `packer` installed

```sh
$ brew install cirruslabs/cli/tart
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/packer
```

## Create a base image

Run the following to creates a `base` VM in tart that can be used as a starting point for the runner. The script should then complete the macOS setup on its own.

```sh
$ packer init base.pkr.hcl
$ packer build base.pkr.hcl
```

By default, this will download the latest MacOS recovery image and configure a VM from it. Alternatively, a URL or a path for the image to use can be specified. Available recovery images can be found here: https://ipsw.me/

```
$ packer build base.pkr.hcl -var "ipsw=PATH_OR_URL_TO_IPSW"
```

## Create a runner image

Run the following to create a clone from `base` VM and configure it with the necessary tools for a runner

```sh
$ packer build runner.pkr.hcl
```

## Install the Host's SSH Key

Install the host's public key on the VM. This will allow the host's script to launch commands inside the VM.

```sh
$ tart run runner
$ ssh-copy-id -i SSH_KEY_FILE runner@$(tart ip runner)
```

## Install Xcode

Xcode cannot be installed automatically from the script as it requires a 2FA with an Apple ID. It can be installed with [xcodes](https://github.com/RobotsAndPencils/xcodes) from within the VM.

```sh
$ xcodes install --latest --experimental-unxip
$ sudo xcode-select -s "/Applications/$(ls /Applications | grep -m 1 Xcode)"
$ sudo xcodebuild -license accept
$ sudo xcodebuild -runFirstLaunch
$ sudo xcodebuild -downloadAllPlatforms
```

## Push the image on the container registry

The new image can be pushed to a registry to facilitate the distribution. Follow the [registry configuration guide](registry/README.md) to get one running.

```
$ tart login REGISTRY_URL
$ tart push runner REGISTRY_URL/runner:latest
```

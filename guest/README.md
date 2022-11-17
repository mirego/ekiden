# Guest Configuration
The templates for this projet were adapted from the [cirruslab templates](https://github.com/cirruslabs/macos-image-templates).

## Prerequisite

- Install `tart`
  - `brew install cirruslabs/cli/tart`
- Install `packer`
  - `brew tap hashicorp/tap`
  - `brew install hashicorp/tap/packer`

## Create a base image

- Run `packer build base.pkr.hcl`
  - This will download the latest MacOS recovery image and configure a VM from it
  - Available recovery images can be found here: https://ipsw.me/
  - A URL for the image to use can be specified with `packer build base.pkr.hcl -var "ipsw=https://updates.cdn-apple.com/2022FallFCS/fullrestores/012-93802/A7270B0F-05F8-43D1-A9AD-40EF5699E82C/UniversalMac_13.0.1_22A400_Restore.ipsw"`
  - A path for a downloaded recovery image to use can be specified with `packer build base.pkr.hcl -var "ipsw=Downloads/UniversalMac_13.0.1_22A400_Restore.ipsw"`
  - This creates a `base` VM in tart that can be used as is or as a starting point for another VM

## Create a runner image

- Run `packer build runner.pkr.hcl`
  - This will create a clone from `base` VM and configure it with the necessary tools for a runner
  - The resulting VM can be uploaded to an OCI compatible registry
- Install the host's public key on the VM
  - `tart run runner`
  - `ssh-copy-id runner@$(tart ip runner)`
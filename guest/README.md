# Guest Configuration
The templates for this projet were adapted from the [cirruslab templates](https://github.com/cirruslabs/macos-image-templates).

## Prerequisite

- Install `tart`
  - `brew install cirruslabs/cli/tart`
- Install `packer`
  - `brew tap hashicorp/tap`
  - `brew install hashicorp/tap/packer`

## Create a base image

- Run `packer build guest/base.pkr.hcl`
  - This will download the latest MacOS recovery image and configure a VM from it
  - This creates a `base` VM in tart that can be used as is or as a starting point for another VM

## Create a runner image

- Run `packer build guest/runner.pkr.hcl`
  - This will create a clone from `base` VM and configure it with the necessary tools for a runner
  - The resulting VM can be uploaded to an OCI compatible registry
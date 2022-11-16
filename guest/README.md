
## Create a new VM

- Download a Mac OS recovery image. The download URL can be found [here](https://ipsw.me/).
- Create the VM
  - The VM should have enough space for all the necessary tools.
  - Example command: `./macosvm --disk disk.img,size=128g --aux aux.img -c 8 --restore UniversalMac_Restore.ipsw vm.json`
  - The VM configuration is saved to the specified JSON file.

## Setup the VM

1. Start the VM in a non-ephemeral mode
   - `./macosvm vm.json -g`
2. Go through the MacOS initial setup
   - Username: `runner`
   - Password: `runner`
3. Enable remote access (SSH)
4. Set the hostname for the SSH communication to `githubrunnervm`
5. Add the public key to the allowed list
   - From the host machine, you can run `ssh-copy-id runner@githubrunnervm.local` to copy the public key to the guest
6. Disable automatic updates
7. Disable sleep
8. Enable passwordless `sudo`
   - `sudo visudo`
   - Edit to have `%admin ALL=(ALL) NOPASSWD: ALL`
9. Download [the runner](https://github.com/actions/runner/releases)
   - Make sure to download the ARM64 version, otherwise everything will run through Rosetta
10. Install Homebrew
    - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
11. Install Xcode from the website
    - Must be downloaded from the [website](https://developer.apple.com/xcode/) as the App Store is currently disabled inside a VM
    - Make sure to start Xcode once to install all the components
12. Install the Android SDK
13. Install additionnal tools from Homebrew
    - `jq`
    - `curl`
    - `wget`
    - `firebase-cli`
    - `awscli`
    - `rbenv`, `ruby-build` and `rbenv-bundler`
    - `python3`
14. Set the required environment variables
    - Variables can be defined in the `.env` file in the runner folder
    - `ImageOS` must be set to `macos{VERSION}`
    - `XCODE_13_DEVELOPER_DIR` must point to Xcode's path
    - `PATH` should include all the installed binaries

Example `.env` file:

```
LANG=en_CA.UTF-8
ImageOS=macos12
XCODE_13_DEVELOPER_DIR=/Applications/Xcode-13.app/Contents/Developer
XCODE_14_DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
ANDROID_HOME=/Users/$USER/Library/Android/sdk
PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

## Caveats

- GitHub's cache action will not work across different architectures
- The `ruby/setup-ruby` action will not work as there are not ARM64 binaries provided at the moment. A workaround is to use rbenv.

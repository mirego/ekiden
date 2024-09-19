#!/bin/bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
{
  echo "export LANG=en_US.UTF-8"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  echo "export HOMEBREW_NO_AUTO_UPDATE=1"
  echo "export HOMEBREW_NO_INSTALL_CLEANUP=1"
} >>~/.zprofile
source ~/.zprofile
brew update
brew install wget cmake gcc git-lfs jq unzip zip ca-certificates awscli
git lfs install

# Install GitHub Runner
mkdir actions-runner && cd actions-runner || exit
RUNNER_TAG=$(curl -sL https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name')
RUNNER_VERSION=$${RUNNER_TAG:1}
curl -O -L https://github.com/actions/runner/releases/download/$RUNNER_TAG/actions-runner-osx-arm64-$RUNNER_VERSION.tar.gz
tar xzf ./actions-runner-osx-arm64-$RUNNER_VERSION.tar.gz
rm actions-runner-osx-arm64-$RUNNER_VERSION.tar.gz

# Install asdf and plugins
brew install asdf
echo ". $(brew --prefix asdf)/libexec/asdf.sh" >>~/.zprofile
source ~/.zprofile
asdf plugin add nodejs
asdf plugin add java
asdf plugin add ruby
asdf plugin add python

# Rosetta
sudo softwareupdate --install-rosetta --agree-to-license

# Android SDK
brew install --cask temurin
brew install android-commandlinetools android-ndk
{
  echo "export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools"
  echo "export ANDROID_SDK_ROOT=/opt/homebrew/share/android-commandlinetools"
  echo "export ANDROID_NDK_HOME=/opt/homebrew/share/android-ndk"
} >>~/.zprofile
source ~/.zprofile
sdkmanager --update
yes | sdkmanager --licenses
sdkmanager tools platform-tools emulator
yes | sdkmanager "platforms;android-30" "build-tools;30.0.2" "cmdline-tools;latest"
echo 'export PATH=$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH' >>~/.zprofile

# Install Xcode
brew install robotsandpencils/made/xcodes aria2
sudo xcodes install --latest --experimental-unxip
sudo xcode-select -s "/Applications/$(ls /Applications | grep -m 1 Xcode)"
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -downloadAllPlatforms

# Install Certificates
sudo security authorizationdb write com.apple.trust-settings.admin allow

wget https://developer.apple.com/certificationauthority/AppleWWDRCA.cer
wget https://www.apple.com/certificateauthority/AppleWWDRCAG2.cer
wget https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer
wget https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer
wget https://www.apple.com/certificateauthority/AppleWWDRCAG5.cer
wget https://www.apple.com/certificateauthority/AppleWWDRCAG6.cer
sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCA.cer
sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG2.cer
sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG3.cer
sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG4.cer
sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG5.cer
sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG6.cer
rm AppleWWDRCA.cer
rm AppleWWDRCAG2.cer
rm AppleWWDRCAG3.cer
rm AppleWWDRCAG4.cer
rm AppleWWDRCAG5.cer
rm AppleWWDRCAG6.cer

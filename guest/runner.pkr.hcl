packer {
  required_plugins {
    tart = {
      version = ">= 0.5.1"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

source "tart-cli" "tart" {
  vm_base_name = "base"
  vm_name      = "runner"
  cpu_count    = 7
  memory_gb    = 7
  disk_size_gb = 120
  ssh_password = "runner"
  ssh_username = "runner"
  ssh_timeout  = "120s"
}

build {
  sources = ["source.tart-cli.tart"]

  // Homebrew
  provisioner "shell" {
    inline = [
      "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"",
      "echo \"export LANG=en_US.UTF-8\" >> ~/.zprofile",
      "echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile",
      "echo \"export HOMEBREW_NO_AUTO_UPDATE=1\" >> ~/.zprofile",
      "echo \"export HOMEBREW_NO_INSTALL_CLEANUP=1\" >> ~/.zprofile",
      "source ~/.zprofile",
      "brew --version",
      "brew update",
      "brew install wget cmake gcc git-lfs jq unzip zip ca-certificates awscli",
      "git lfs install",
    ]
  }

  // GitHub Runner
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "cd $HOME",
      "mkdir actions-runner && cd actions-runner",
      "RUNNER_TAG=$(curl -sL https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name')",
      "RUNNER_VERSION=$${RUNNER_TAG:1}",
      "curl -O -L https://github.com/actions/runner/releases/download/$RUNNER_TAG/actions-runner-osx-arm64-$RUNNER_VERSION.tar.gz",
      "tar xzf ./actions-runner-osx-arm64-$RUNNER_VERSION.tar.gz",
      "rm actions-runner-osx-arm64-$RUNNER_VERSION.tar.gz",
    ]
  }

  // asdf
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew install asdf",
      "echo \". $(brew --prefix asdf)/libexec/asdf.sh\" >> ~/.zprofile",
      "source ~/.zprofile",
      "asdf plugin add nodejs",
      "asdf plugin add java",
      "asdf plugin add ruby",
      "asdf plugin add python",
    ]
  }

  // Rosetta
  provisioner "shell" {
    inline = [
      "sudo softwareupdate --install-rosetta --agree-to-license"
    ]
  }

  // Android SDK
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew install --cask temurin",
      "brew install android-commandlinetools android-ndk",
      "echo \"export ANDROID_HOME=/opt/homebrew/share/android-sdk\" >> ~/.zprofile",
      "echo \"export ANDROID_SDK_ROOT=/opt/homebrew/share/android-sdk\" >> ~/.zprofile",
      "echo \"export ANDROID_NDK_HOME=/opt/homebrew/share/android-ndk\" >> ~/.zprofile",
      "source ~/.zprofile",
      "sdkmanager --update",
      "yes | sdkmanager --licenses",
      "sdkmanager tools platform-tools emulator",
      "yes | sdkmanager \"platforms;android-30\" \"build-tools;30.0.2\" \"cmdline-tools;latest\"",
      "echo 'export PATH=$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH' >> ~/.zprofile"
    ]
  }

  // Xcode
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew install robotsandpencils/made/xcodes aria2",

      // There is an issue with xcodes preventing the download without being logged in (https://github.com/RobotsAndPencils/xcodes/issues/243).
      // As the apple account requires a 2 factor validation, this step will have to be performed manually.
      // "sudo xcodes install --latest --experimental-unxip",
      // "sudo xcode-select -s \"/Applications/$(ls /Applications | grep -m 1 Xcode)\""
      // "sudo xcodebuild -license accept"
      // "sudo xcodebuild -runFirstLaunch",
      // "sudo xcodebuild -downloadAllPlatforms",
    ]
  }

  // Cert
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      
      // Allow admin settings change in a non interactive shell
      "sudo security authorizationdb write com.apple.trust-settings.admin allow",
      
      "wget https://developer.apple.com/certificationauthority/AppleWWDRCA.cer",
      "sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCA.cer",
      "rm AppleWWDRCA.cer",

      "wget https://www.apple.com/certificateauthority/AppleWWDRCAG2.cer",
      "sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG2.cer",
      "rm AppleWWDRCAG2.cer",

      "wget https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer",
      "sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG3.cer",
      "rm AppleWWDRCAG3.cer",

      "wget https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer",
      "sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG4.cer",
      "rm AppleWWDRCAG4.cer",

      "wget https://www.apple.com/certificateauthority/AppleWWDRCAG5.cer",
      "sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG5.cer",
      "rm AppleWWDRCAG5.cer",

      "wget https://www.apple.com/certificateauthority/AppleWWDRCAG6.cer",
      "sudo security add-trusted-cert -d -r unspecified -k /Library/Keychains/System.keychain AppleWWDRCAG6.cer",
      "rm AppleWWDRCAG6.cer",
    ]
  }
}

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
  disk_size_gb = 80
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
      "brew install wget cmake gcc git-lfs jq unzip zip ca-certificates",
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

  // Ruby
  provisioner "shell" {
    inline = [
      "source ~/.zprofile",
      "brew install rbenv",
      "echo 'if which rbenv > /dev/null; then eval \"$(rbenv init -)\"; fi' >> ~/.zprofile",
      "source ~/.zprofile",
      "rbenv install 3.0.4",
      "rbenv global 3.0.4",
      "sudo gem install bundler",
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
      "brew install --cask homebrew/cask-versions/temurin8",
      "brew install android-sdk android-ndk",
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
      "sudo xcodes install --latest --experimental-unxip",
      "sudo xcodebuild -runFirstLaunch",
    ]
  }
}

# Host Configuration

## UI

### Complete the macOS setup

Use `admin` as the username for the initial user

### Adjust the machine’s preferences:

- Sharing — Enable Screen sharing
- Sharing — Enable Remote access (SSH/Remote Desktop)
- Sharing — Edit machine hostname (`gh-shr-XX`)
- Energy — Disable sleep

## CLI

### Install SSH Key

From your local machine, copy your public SSH key (eg. `~/.ssh/id_rsa.pub`) to the machine

  ```
  # You’ll be prompted for admin’s password just this one time
  $ ssh-copy-id -i ~/.ssh/id_rsa.pub admin@<HOST_IP>
  ```

### Copy Files
Still from your local machine, copy a few files from this repository. The `.env` contains the secrets for the runner (see `.env.example` for a template)

  ```
  $ scp .zshrc admin@<HOST_IP>
  $ scp .vimrc admin@<HOST_IP>
  $ scp launch.sh admin@<HOST_IP>:vm
  $ scp .env admin@<HOST_IP>:vm
  ```

### Install Tools

On the remote machine, install [Homebrew](https://brew.sh), `tmux`, `wget` and [tart](https://github.com/cirruslabs/tart/)

  ```
  $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  $ brew install tmux wget cirruslabs/cli/tart
  ```

### Start the Runner
Start tmux and launch a new runner!

  ```
  $ tmux
  $ cd vm
  $ ./launch.sh
  ```

You can now detach from tmux with (press `^B`, release and then `d`)

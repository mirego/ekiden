
### UI

- In the initial macOS setup
  - Use `admin` as the username for the initial user
- After the macOS setup, adjust the machine’s preferences:
  - Sharing — Enable Screen sharing
  - Sharing — Enable Remote access (SSH/Remote Desktop)
  - Sharing — Edit machine hostname (`gh-shr-XX`)
  - Energy — Disable sleep
- Put the screen in sleep mode

### CLI

- From your local machine, copy your public SSH key (eg. `~/.ssh/id_rsa.pub`) to the machine

  ```
  # You’ll be prompted for admin’s password just this one time
  $ ssh-copy-id -i ~/.ssh/id_rsa.pub admin@<HOST_IP>
  ```

- Still from your local machine, copy a few files from this repository

  ```
  $ scp .zshrc admin@<HOST_IP>
  $ scp .vimrc admin@<HOST_IP>
  ```

- On the remote machiine, install [Homebrew](https://brew.sh)

  ```
  $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

- Install `tmux` and `wget`

  ```
  $ brew install tmux wget
  ```

- Install [tart](https://github.com/cirruslabs/tart/)

  ```
  $ brew install cirruslabs/cli/tart
  ```

- Configure the setup

  - From your local machine, copy the launch script into the remote machine’s `vm` directory

    ```
    $ scp launch.sh admin@<HOST_IP>:vm
    ```

- Configure the rest of the setup
  ⚠️ **This part is still a work in progress**

  - Configure the value for `GITHUB_API_TOKEN` in `vm/launch.sh`
  - Add the private SSH key to communicate with the VM
  - Fetch the rest of the `vm` directory content from another host machine (using cryptic/fancy `scp` commands)

- Start tmux and launch a new runner!

  ```
  $ tmux
  $ cd vm
  $ ./launch.sh mirego-XX
  ```

- Detach from tmux with (press `^B`, release and then `d`)

- Logout from the remote machine

  ```
  $ exit
  ```

- 🎉
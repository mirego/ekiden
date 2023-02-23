# Host Configuration

## UI

### Complete the macOS setup

Use `admin` as the username for the initial user

### Adjust the machine’s preferences:

- General → Sharing → enable **Screen Sharing**
- General → Sharing → enable **Remote Login**
- General → Sharing → edit **Hostname** (`gh-shr-XX`)
- Displays → Advanced… → Energy → enable **Prevent automatic sleeping when display is off**

<table>
  <tr>
    <th>Sharing
    <th>Displays
  <tr>
    <td><img width="300" alt="" src="https://user-images.githubusercontent.com/11348/213275950-7e9976dc-f2b4-456f-a915-fcda26af6afc.png">
    <td><img width="300" alt="" src="https://user-images.githubusercontent.com/11348/213275979-c53d5c69-2028-4277-aef3-3af502dcdba6.png">
</table>

## CLI

### Install SSH Key

From your local machine, copy your public SSH key (eg. `~/.ssh/id_rsa.pub`) to the machine

```
# You’ll be prompted for admin’s password just this one time
$ ssh-copy-id -i ~/.ssh/id_rsa.pub admin@<HOST_IP>
```

### Copy Files

Still from your local machine, copy a few files from this repository. The `domain.crt` file is the certificate required to access the VM registry. The `.env` contains secrets for the runner (see `.env.example` for a template). An ssh key is also installed on the host to facilitate the connection to the VM.

```
$ scp domain.crt admin@<HOST_IP>
$ scp launch.sh admin@<HOST_IP>:vm
$ scp .env admin@<HOST_IP>:vm
$ scp id_rsa admin@<HOST_IP>:.ssh
$ scp id_rsa.pub admin@<HOST_IP>:.ssh
```

### Install Tools

On the remote machine, install [Homebrew](https://brew.sh), `tmux`, `wget` and [tart](https://github.com/cirruslabs/tart/)

```
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
$ brew install tmux wget cirruslabs/cli/tart
```

### Install Certificate

Open the certificate in the keychain and make sure it is marked as "Always Trust".
Alternatively, this can also be done from command line:

```
$ sudo security authorizationdb write com.apple.trust-settings.admin allow
$ security unlock-keychain ~/Library/Keychains/login.keychain-db
$ security add-trusted-cert -d -k ~/Library/Keychains/login.keychain domain.crt
```

### Start the Runner

Start tmux and launch a new runner!

```
$ tmux
$ cd vm
$ ./launch.sh
```

You can now detach from tmux with (press `^B`, release and then `d`)

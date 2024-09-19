# Host Configuration

## UI

### Complete the macOS setup

Use `admin` as the username for the initial user

### Adjust the machine’s preferences:

- General → Sharing → enable **Screen Sharing**
- General → Sharing → enable **Remote Login**
- General → Sharing → edit **Hostname** (`gh-shr-XX`)
- General → About → edit **Name** (`gh-shr-XX`)
- Displays → Advanced… → Energy → enable **Prevent automatic sleeping when display is off**
- Energy Saver → enable **Start up automatically after a power failure**

<table>
  <tr>
    <th>Sharing
    <th>Displays
    <th>Energy Saver
  <tr>
    <td><img width="300" alt="" src="https://user-images.githubusercontent.com/11348/213275950-7e9976dc-f2b4-456f-a915-fcda26af6afc.png">
    <td><img width="300" alt="" src="https://user-images.githubusercontent.com/11348/213275979-c53d5c69-2028-4277-aef3-3af502dcdba6.png">
    <td><img width="300" alt="" src="https://user-images.githubusercontent.com/11348/236463635-bbfb2c79-5494-4937-8ba7-c622754e358a.png">
</table>

## CLI

### Install SSH Key

From your local machine, copy your public SSH key (eg. `~/.ssh/id_rsa.pub`) to the machine

```
# You’ll be prompted for admin’s password just this one time
$ ssh-copy-id -i ~/.ssh/id_rsa.pub admin@<HOST_IP>
```

### Copy Files

Still from your local machine, copy a few files from this repository. The `.env` contains configurations for the runner (see `.env.example` for a template).

```
$ scp launch.sh admin@<HOST_IP>:vm
$ scp com.mirego.ekiden.plist admin@<HOST_IP>:vm
$ scp .env admin@<HOST_IP>:vm
```

### Install Tools

On the remote machine, install [Homebrew](https://brew.sh), `wget`, `sshpass` and [tart](https://github.com/cirruslabs/tart/)

```
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
$ brew install wget cirruslabs/cli/tart cirruslabs/cli/sshpass
```

### Start the Runner

Install the service and launch it.

```
$ sudo chown root:wheel launch.sh
$ sudo cp com.mirego.ekiden.plist /Library/LaunchDaemons
$ sudo launchctl load -w /Library/LaunchDaemons/com.mirego.ekiden.plist
```

You can now logout from the server.

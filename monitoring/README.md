# Monitoring

This section describe how to setup a Grafana instance on one of the hosts in order to have a dashboard to monitor the machines.
This strategy is a work in progress and does not implement any form of security. **Use at your own risk**

This strategy uses 3 components:

- [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) to collect the logs from the hosts (installed on every machine).
- [Loki](https://grafana.com/oss/loki/) to collect the logs on the main host.
- [Grafana](https://grafana.com/) to create the dashboard.

## Prerequisites

```
$ brew install colima docker docker-compose
$ colima start
```

## Configuration

- Download the _monitoring_ folder from this repo to the machine.

  ```
  $ scp -r monitoring admin@<HOST_IP>:grafana
  ```

- Replace the HOST_URL and the MACHINE_NAME in promtail's configuration files.
- Replace the HOST_URL in the `docker-compose.yaml`

## Start the Containers

On the remote machine, install the service and launch it.

```
$ sudo chown root:wheel launch.sh
$ sudo cp com.mirego.ekiden-monitoring.plist /Library/LaunchDaemons
$ sudo launchctl load -w /Library/LaunchDaemons/com.mirego.ekiden-monitoring.plist
```

## Post-Launch Configuration

- _Optionally_ import the pre-built dashboard in the _grafana_ folder

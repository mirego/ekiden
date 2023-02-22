# Monitoring

This section describe how to setup a Grafana instance on one of the hosts in order to have a dashboard to monitor the machines.
This strategy is a work in progress and does not implement any form of security. **Use at your own risk**

This strategy uses 3 components:
- [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) to collect the logs from the hosts (installed on every machine).
- [Loki](https://grafana.com/oss/loki/) to collect the logs on the main host.
- [Grafana](https://grafana.com/) to create the dashboard.

## Prerequisites

- Install [Docker](https://www.docker.com/)

## Configuration

- Download the _monitoring_ folder from this repo to the machine.
- Replace the HOST_URL and the MACHINE_NAME in promtail's configuration files.
- Replace the HOST_URL in the `docker-compose.yaml`
- Launch all components with `docker compose up -d`
- _Optionally_ import the pre-built dashboard in the _grafana_ folder

# Registry Configuration

Tart supports uploading images to an OCI registry. This section describes how to setup Gitea as a container registry.

## Prerequisite

```
$ brew install colima docker docker-compose
$ colima start
```

## Prepare the machine

1. Create a `registry` folder
2. Copy the `docker-compose.yaml` file in the folder
3. Create a `certs` sub-folder with the `domain.crt` and `domain.key` files (see [below](#generate-a-certificate) if you need to generate one)
4. Create a `data` sub-folder

## Run the registry

1. From the `registry` folder, run `docker-compose up -d`
2. Follow the instructions on the Gitea interface

## Generate a certificate

Replace `SERVER_IP` with the actual IP.

```sh
openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -addext "subjectAltName = IP:SERVER_IP" \
  -x509 -days 365 -out certs/domain.crt
```

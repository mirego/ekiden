# Registry Configuration

## Prerequisite

- Install [Docker](https://www.docker.com/)
- Install `htpasswd` (preinstalled on MacOS)

## Prepare the machine

1. Create a `registry` folder in the user's home
2. Copy the `docker-compose.yaml` file in the folder
3. Create a `certs` sub-folder with the `domain.crt` and `domain.crt` files (see [below](#generate-a-certificate) if you need to generate one)
4. Create an `auth` sub-folder
5. Run `htpasswd -cB auth/registry.password USER` to create a new password file

## Run the registry

1. From the `registry` folder, run `docker compose up -d`
2. Additionnal users can be added with `htpasswd -B auth/registry.password USER`

## Generate a certificate

Replace `SERVER_IP` with the actual IP.

```sh
openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -addext "subjectAltName = IP:SERVER_IP" \
  -x509 -days 365 -out certs/domain.crt
```

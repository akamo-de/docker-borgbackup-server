# Dockerized Backup Server using Borg and OpenSSH

## Introduction
An easy way to run borg backup in a container with isolated SSH server.

## Software

 * [borg backup](https://borgbackup.readthedocs.io/): Backup software that is doing the actual software
 * [ed25519](https://ed25519.cr.yp.to/): Curve25519 is an elliptic curve offering 128 bits of security (256 bits key size); used within the SSH server

## Setup

### Docker-Compose:

> Clone this repo

~~~~
$ git clone https://github.com/akamo-de/docker-borgbackup-server.git
~~~~

> Create a docker-compose.yml file and change it as you like

~~~~
version: '2'
services:
  backup-destination:
    container_name: my-cool-backup
    build: docker-borgbackup-server/.
    restart: always
    environment:
      SYSTEM_NAME: my-cool-backup
      BORG_PASSPHRASE:
      BORG_QUOTA:
    volumes:
      - /path/to/local/persistance/directory:/backup/destination
    ports:
      - 0.0.0.0:12345:2222
~~~~



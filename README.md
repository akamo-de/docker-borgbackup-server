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

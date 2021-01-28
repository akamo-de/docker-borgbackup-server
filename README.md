# Dockerized Backup Server using Borg and OpenSSH

## Introduction
An easy way to run borg backup in a container with isolated SSH server.

## Software

 * [borg backup](https://borgbackup.readthedocs.io/): Backup software that is doing the actual software
 * [ed25519](https://ed25519.cr.yp.to/): Curve25519 is an elliptic curve offering 128 bits of security (256 bits key size); used within the SSH server

## Setup

### Docker-Compose:

> Create a docker-compose.yml file. The following template may be changed it as you require:

~~~
version: '2'
services:
  backup-destination:
    container_name: my-cool-backup
    image: akamo/borgbackup-server
    restart: always
    environment:
      SYSTEM_NAME: my-cool-backup
      BORG_PASSPHRASE:
      BORG_QUOTA:
    volumes:
      - /path/to/local/persistance/directory:/backup/destination
    ports:
      - 0.0.0.0:12345:2222
~~~

Changing the environment may affect the following behaviour:

**SYSTEM_NAME**: The system name is used for ssh-key generation only (at present).

**BORG_PASSPHRASE**: This is the initial password for the borg backup repository during init process. The password is generated if no password is provided. This variable is used during init-process of the repository only (i.e. only the first time).

**BORG_QUOTA**: This value (if set) can limit the storage quota of the borg server. See `storage quota` property of [`borg serve`](https://borgbackup.readthedocs.io/en/stable/usage/serve.html) command for more information.

Whithin volumes, this container requires RW-Access to an empty directory. Assuming the directory in the template ahead, the container creates the following structure:

`/path/to/local/persistance/directory/backup`: This is the borg backup repository.

`/path/to/local/persistance/directory/backup_id_enc`: This is an encoded version of the public key for the authorized SSH user. If you are using the akamo borg client container, this string can be used directly. Otherwise (if you need the key for your own script) you can use linux commands to extract it, for example `cat backup_id_enc |base64 -d|gunzip`.

`/path/to/local/persistance/directory/borg_key`: This is the borg repository (encrypted) key. It is extracted using the [`borg key export`](https://borgbackup.readthedocs.io/en/stable/usage/key.html#borg-key-export) command.

`/path/to/local/persistance/directory/borg_pwd`: This file contains the borg repository password used for initialization. If you do not need it anymore, you may remove this file. But keep in mind that both the key and the password files are required for restore process. If your backup source dies for some reason and you don´t have the password saved anywhere else, the data is inaccessible.

`/path/to/local/persistance/directory/ssh`: This is the directory containing the SSH server key and the ssh authorized ID for later backup client login.

The directories (`ssh` and `backup`) are required to for the functionality. The other files are there for safety reason only.

The path `/backup/destination` is the hard coded path for the docker container to find the files. Do not change this path until you know what you are doing.

In addition, the local SSH server port `2222` is used, because the ssh service is running as non-priviliged user within the container.


If you need support - please ask [us](https://akamo.de).

# Yukon Server

Visit the Discord server for more support.

[![Yukon Discord members](https://badgen.net/discord/members/NtYtpzyxBu)](https://discord.gg/NtYtpzyxBu)

## Built With

* [Node.js](https://nodejs.org/en/)
* [Socket.IO](https://socket.io/)
* [Sequelize](https://sequelize.org/)

## Local Installation (Development setup)

These instructions will get you a copy of the project up and running on your local machine for development purposes.

### Prerequisites

* [A MySQL database](https://www.mysql.com/)
* [Node.js](https://nodejs.org/en/)
* [yukon](https://github.com/wizguin/yukon)
* Docker

### Optional
* [mycli](https://github.com/dbcli/mycli)

### Installation

1. Clone this repository.

```sh
$ git clone https://github.com/mluna-again/penguins
```

2. Build containers
```sh
$ docker compose build
```

3. Setup database
```sh
$ docker compose up mysql
```

4. (In other terminal window, wait for previous step to finish) Prepare database schema
```sh
$ docker container ls # get database container ID and copy it, look for something like "server-mysql"

$ docker container exec -it <mysql_container_id> bash
$ mysql -D yukon -h mysql
mysql> create database yukon;
mysql> connect yukon;
mysql> source ./yukon.sql; # if no errors show up, type Ctrl-D to exit
$ exit
```

5. Stop previous compose and restart
```sh
# return to previous terminal window and type ctrl-c
# you should see something like this:
# [+] Stopping 2/2...
$ docker compose up
```

### Creating a user
You can manually insert a user to the database, but in order to make it easier there is the create_user.sh script:
```sh
$ ./create_user.sh <user> <password>
```
You can see `create_user.sh` details instructions like this:
```sh
$ ./create_user.sh # no arguments
```

### Usage
* Building the server for production.

```console
npm run build
```

* Running the server in production mode. This will start all worlds listed in config.json.

```console
npm run start
```

* Stopping production servers.

```console
npm run stop
```

* Restarting production servers.

```console
npm run restart
```

* Listing production servers.

```console
npm run list
```

* Display live logs for production servers

```console
npm run logs
```

* PM2 monitor for production servers.

```console
npm run monit
```

* Generate a new crypto secret.

```console
npm run secret-gen
```

### Account creation

The easiest way to create accounts locally would be to simply enter them manually. Make sure to use a bcrypt hashed password, a tool such as [this](https://www.browserling.com/tools/bcrypt) can be used to generate one.

```console
$2a$10$nAxC5GXU0i/dacalTX.iZuRrtpmwmZ9ZzL.U3Zroh0jeSXiswFsne
```

## Production Usage

The following is required when running the project in production.

* The project must first be built using the build command.

```console
npm run build
```

* HTTPS can be configured as follows. Make sure your web server is also configured to use HTTPS.

```console
"socketio": {
    "https": true,
    "ssl": {
        "cert": "/path/to/cert.crt",
        "ca": "/path/to/ca.ca-bundle",
        "key": "/path/to/key.key"
    }
},
```

* The CORS origin must be set. This will likely just be your domain name, e.g "example.com".

```console
"cors": {
    "origin": "example.com"
},
```

* Run the server in production mode.

```console
npm run start
```

## Disclaimer

This project is a work in progress, please report any issues you find [here](https://github.com/wizguin/yukon-server/issues).

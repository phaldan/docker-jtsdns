# JTSDNS

[![](https://images.microbadger.com/badges/version/phaldan/jtsdns.svg)](https://microbadger.com/images/phaldan/jtsdns) [![](https://images.microbadger.com/badges/image/phaldan/jtsdns.svg)](https://microbadger.com/images/phaldan/jtsdns) [![](https://img.shields.io/docker/stars/phaldan/jtsdns.svg)](https://hub.docker.com/r/phaldan/jtsdns/) [![](https://img.shields.io/docker/pulls/phaldan/jtsdns.svg)](https://hub.docker.com/r/phaldan/jtsdns/) [![](https://img.shields.io/docker/automated/phaldan/jtsdns.svg)](https://hub.docker.com/r/phaldan/jtsdns/)

Size optimised Docker image based on [openjdk:8-jre-alpine](https://hub.docker.com/_/openjdk/) image for the [JTSDNS](https://www.stefan1200.de/forum/index.php?topic=208.0) as an alternative TSDNS server with MySQL:

* `1.5.2`, `1.5`, `1`, `latest` ([Dockerfile](https://github.com/phaldan/docker-jtsdns/blob/c5e8364d3afbe16519c5943cc31eda05a7d3b590/Dockerfile))

## Run JTSDNS container

Run with external MySQL:
```
$ docker run -d --name=jtsdns -v ${PWD}/JTSDNS.cfg:/JTSDNS/JTSDNS.cfg -p 41144:41144 phaldan/jtsdns
```

Docker-Compose with MySQL:
```
version: "3"
services:
  jtsdns:
    image: phaldan/jtsdns:1.5.2
    ports:
      - "41144:41144"
    volumes:
      - ./log:/JTSDNS/log
    environment:
      - JTSDNS_MYSQL_HOST=mysql
      - JTSDNS_MYSQL_USER=root
      - JTSDNS_MYSQL_PASSWORD=changeme
      - JTSDNS_MYSQL_DATABASE=jtsdns
      - JTSDNS_LOGFILE=%apphome%log/JTSDNS.log
    links:
      - mysql
  mysql:
    image: mariadb:10
    environment:
      - MYSQL_DATABASE=jtsdns
      - MYSQL_ROOT_PASSWORD=changeme
    volumes:
      - ./mysql:/var/lib/mysql
```

## What is JTSDNS

[JTSDNS](https://www.stefan1200.de/forum/index.php?topic=208.0) is an TSDNS alternative using MySQL as database. In addition to this it also saves to database how often a hostname was requested and the last requested time. Just import the jtsdns.sql to your MySQL database and, if you want, create your own website that adds or edit the entries in that JTSDNS table. The names of the columns are quite self explaining. Like the real TSDNS application wildcards at hostnames are supported.

It can still have bugs, but one user use it already on a server without problems. For more information about the usage, just look in the [readme.txt](https://www.stefan1200.de/documentation/jtsdns/readme.txt).

Example for `JTSDNS.cfg`:

```
# Use a mysql database to save TSDNS configurations.
# There should be a structure sql file in the directory.
# Import this into your MySQL database to create the tables.
# But you must fill this tables by yourself, this program just reads the information out there.
mysql_host = 127.0.0.1
mysql_port = 3306
mysql_user = 
mysql_password = 
mysql_database = 

# Optional MySQL settings, more information on https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-configuration-properties.html#connector-j-reference-set-config
# Possible values: -1 = default, 0 = disable, 1 = enable
mysql_verifyServerCertificate = -1
mysql_useSSL = -1
mysql_requireSSL = -1
mysql_useCompression = -1

# Set a path to a logfile or nothing, if no logfile should be written.
# The logfile contains all information what happened while JTSDNS is started.
# If the app.home environment variable was set, %apphome% will be replaced with the app.home path.
logfile = %apphome%JTSDNS.log
```

## Environment variables

This image extends the JTSDNS with environment variables.

&#x1F534; Mapped to `JTSDNS.cfg` &#x1F537; Initialization parameter

|Variable|Default|Description|
|-----------|---------|---------|
|&#x1F534; JTSDNS_LOGFILE|%apphome%JTSDNS.log||
|&#x1F537; JTSDNS_MYSQL_CREATE_TABLES|1|1=Enabled, 0=Disabled|
|&#x1F534; JTSDNS_MYSQL_DATABASE|&lt;empty&gt;||
|&#x1F534; JTSDNS_MYSQL_HOST|127.0.0.1||
|&#x1F534; JTSDNS_MYSQL_PASSWORD|&lt;empty&gt;||
|&#x1F534; JTSDNS_MYSQL_PORT|3306||
|&#x1F534; JTSDNS_MYSQL_REQUIRE_SSL|-1||
|&#x1F537; JTSDNS_MYSQL_TIMEOUT|60|Connect timeout in seconds|
|&#x1F534; JTSDNS_MYSQL_USE_COMPRESSION|-1||
|&#x1F534; JTSDNS_MYSQL_USE_SSL|-1||
|&#x1F534; JTSDNS_MYSQL_USER|&lt;empty&gt;||
|&#x1F534; JTSDNS_MYSQL_VERIFY_SERVER_CERTIFICATE|-1||


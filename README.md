# Magento Developer Environment
Another development environment for Magento on Docker and Docker Compose, that is simple by default, yet still feature rich.

## Features
* Wide range of supported PHP versions (5.6, 7.0, 7.1, 7.2, 7.3, 7.4)
* Pre-built images as well as customizable source code
* Using NGINX + FastCGI
* MySQL storage using internal Docker volume as well as user directory
* Support for non-standard HTTP ports
* Well integrated with Composer
* Support for legacy Magento
* Built-in XDebug extension
* Optional proxying through third-party services
* PHP's mail function to use any SMTP server
* Built-in NodeJS for assets compilation
* Easy setup using .env file
* Third-party services examples
    * PHPMyAdmin
    * Varnish
    * Redis
    * Elasticsearch
    * Mailcatcher
* Flexible and highly customizable

## User manual
This environment mounts Magento directory within containers to make it easy to work on. It can be used either with existing installation of Magento or with a fresh directory to initialize new project.

### Quick start
1. Clone this repository anywhere you want. It's good practice to use every clone of the repo for each project, as it may contain settings corresponding to a single Magento installation.
2. Copy .env.example file to .env
3. Edit .env file to configure your installation. All variables that are uncommented by default are required or recommended (apart from `COMPOSER_AUTH`)
4. Make sure you have existing directories for Composer and NPM cache (`~/.composer/cache`, `~/.npm`) or point them to your custom directories in .env
5. Make sure your `~/.ssh` directory exists.
6. Optionally validate your configuration by executing script in the environment's root directory

    ```
    ./validate.sh
    ```

7. If you want to use pre-built docker images (**recommended**) you need to pull them from Docker Hub

    ```
    docker-compose pull
    ```

    If you want to build images by yourself, type

    ```
    docker-compose build
    ```

8. Finally run the environment

    ```
    docker-compose up
    ```

9. Optionally, copy docker-compose.custom.yml.example to docker-compose.custom.yml, uncomment some services or write your own and run

    ```
    docker-compose -f docker-compose.yml -f docker-compose.custom.yml up
    ```

### How does it work
The best way to figure out how the environment with all its features work, is to examine docker-compose.yml and images source files (docker/mariadb, docker/nginx, docker/php). The most important thing to know is that by default it uses three services responsible for different tasks:
* `app` container - includes PHP interpreter with extensions that Magento require, PHP-FPM daemon for web server, tools such as Composer, NodeJS & NPM for assets building and some configurations to make custom features work.
* `web` container - includes NGINX web server configured for Magento.
* `db` container - includes MariaDB database server with configuration to support flexible variable storage placement.

### Environment options
#### General
* `COMPOSE_PROJECT_NAME`: Variable used by Docker Compose. Indicates prefix for all Docker objects like containers, images and networks. Should be unique for project. Interfering project names will cause environment unable to initialize.

* `UID` and `GID`: Unix user and group identificators for new processes that may modify data in user directory. Should be the same as for current user. You can check that using

    ```
    id -u # for UID
    id -g # for GID
    ```

* `PHP_VERSION`: Self explanatory. Can be one of:
    * 5.6
    * 7.0
    * 7.1
    * 7.2
    * 7.3
    * 7.4

* `MAGENTO_PATH`: Application directory. The path should be in UNIX format, though it can be relative or absolute. The directory may contain Magento files or be empty for new project init. When using default mode, the `/pub` subdirectory will be used as web server document root. When using `MAGENTO_1_MODE`, the directory will be document root itself.

* `HTTP_EXTERNAL_PORT`: A port number to use for the HTTP daemon. The value may contain an integer as well as address with port in case you want to bind on different interface (by default 0.0.0.0 is used, so that the server listens on all interfaces). For instance you can limit to just the localhost (`127.0.0.1:80`) or to local area network (`192.168.1.1:80`).

#### MariaDB
* `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`: Settings for the database server. Once `db` container is initialized, those values should *not* be changed, unless you plan to reinitialize MariaDB by deleting its files.

* `MYSQL_USER_DIRECTORY` *(optional)*: If set, `db` container will use provided path as variable storage for MariaDB server. This should be UNIX formatted path and the directory has to exist and to be writtable by current user. Generated files modes will follow the `UID` and `GID` settings.

#### Composer
* `COMPOSER_AUTH_FILE` *(optional)*: JSON formatted file path to be mounted inside the `app` container to provide authentication credentials for Composer. See more here: https://getcomposer.org/doc/articles/http-basic-authentication.md

* `COMPOSER_AUTH` *(optional)*: Instead of providing a file path, you may want to save the credentials directily in the .env file. The value should be valid JSON inline string.

* `COMPOSER_INSTALL_ON_BOOT` *(optional)*: When set to true, the `composer install` command will be automatically triggered when the `app` container is starting.

#### Mounted directories
You may want to customize some of the mounted directories - for example you may want to use separate Composer cache directory for single Magento project, or avoid mounting your `~/.ssh` folder by providing `/dev/null` instead. You can change those using following variables:
* `SSH_DIRECTORY`
* `NPM_DIRECTORY`
* `COMPOSER_CACHE_DIRECTORY`

#### XDebug
By default, the `app` container entrypoint will try to guess how you run your environment. If `host.docker.internal` hostname can be resolved, it will be used. Unfortunately this doesn't work the same on every Docker Engine implementation, and for now this way it will only work on MacOS. If it's not resolvable, `connect_back` mechanism will be used - which only works on Docker on Linux. Though connection target can be customized using following vars:

* `XDEBUG_REMOTE_HOST` *(optional)*: Target IP addres of the host you're runing your debugger at. This IP has to be reachable from the container. You may need to check your firewall settings if you're sure that's the correct address, but XDebug can't still connect.

* `XDEBUG_REMOTE_PORT` *(optional)*: By default it's 9000, but you can use any available port you like.

When using XDebug with from container, you will also need to configure paths mapping in your debugger. Inside container, the app root that points to `MAGENTO_PATH` is `/app`.

#### Proxy through
This features enable proxying HTTP traffic to your Magento instance through a third-party service. It can be useful when there's a need to test if some custom module behaves well with full page cache (like Varnish), or you want to use some debugging or monitoring tool. The idea is to point where the HTTP trafic has to go and then, on external service, go back to the `web` container. Specifically, additional service has to proxy again to `http://web:58080` in order to make it work.

* `PROXY_THOROUGH` *(optional)*: HTTP URL to use as a proxy. The service that it points must be reachable by the `web` container. If you want to use Varnish service definition from `docker-compose.custom.yml.example`, this value can be `http://varnish`.

#### Sendmail SMTP
You might need to test outgoing e-mails, e.g. while coding a custom message template. Magento uses [PHP's mail function](https://www.php.net/manual/en/function.mail), which then calls system command (by default it's `sendmail`) to send the message. The environment uses [MSMTP](https://marlam.de/msmtp/) client allowing you to use any SMTP server for the delivery. The `docker-compose.custom.yml.example` contains [Mailcatcher](https://mailcatcher.me/) service, which is very convinient, because it catches every single email, no matter where it's being sent. Some external SMTP servers like [Mailtrap.io](https://mailtrap.io/) can be used as well.
The configuration will be set in the container only if the `SENDMAIL_SMTP_HOST` is defined.

* `SENDMAIL_SMTP_HOST` *(optional)*: Can be a name of docker-compose service or any external host name/IP.
* `SENDMAIL_SMTP_PORT` *(optional)*: SMTP server port numer. Default: 25
* `SENDMAIL_SMTP_AUTH` *(optional)*: Can be 'on' or 'off'. Defaukt: off
* `SENDMAIL_SMTP_TLS` *(optional)*: Can be 'on' or 'off'. Default: off
* `SENDMAIL_SMTP_USER` *(optional)*: SMTP username. Default: user
* `SENDMAIL_SMTP_PASSWORD` *(optional)*: SMTP password. Default: password
* `SENDMAIL_SMTP_FROM` *(optional)*: Default: magento@internal.app

### Interacting with containers
For common tasks like Composer package management or dealing with Magento configuration, we use CLI interface. We need to do that from within container in order to use the proper PHP version, access database and use the same PHP configuration that Magento accessed through webserver does. For sake of simplicity, we only talk to the `app` container.

#### Attaching to the `app` container
You can run bash session inside app container with a simple call

```
docker-compose exec app bash
```

Or you can run every command directly by replacing `bash` with whatever you want. By default, it will always use defined `MAGENTO_PATH` as working directory. For example you can run every Magento CLI command by calling

```
docker-compose exec app php bin/magento ...
```

#### Importing MySQL database
```
docker-compose exec -T app mysql < /path/to/file.sql
```

#### Exporting MySQL database
```
docker-compose exec -T app mysqldump nazwabazy > /path/to/file.sql
```

#### NodeJS and NPM
The `app` container has both `node` and `npm` commands available. Currently it uses NodeJS v12 LTS.

```
docker-compose exec app npm i # install Node modules
docker-compose exec app node_modules/grunt/bin/grunt watch # run a Grunt task
```

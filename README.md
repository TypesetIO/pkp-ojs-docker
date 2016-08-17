Dockerizing OJS (Open Journal Systems) - PKP
============================================
Open Journal Systems (OJS) is a journal management and publishing system that has been developed by the Public Knowledge Project through its federally funded efforts to expand and improve access to research.

###How to use this image###
```
$docker run -p 80:80 --link some-mysql:mysql -d infrascielo/pkp-ojs
```
* -e OJS_DB_HOST=... (default top localhost. Must be change to IP and port of the linked mysql container)
* -e OJS_DB_USER=... (default to ojs)
* -e OJS_DB_PASSWORD=... (default to ojs)
* -e OJS_DB_NAME=... (default to ojs)
* -e SERVERNAME=...(default to ojs-v3.scielo.org)
* -e APACHE_LOG_DIR=... (default to /var/log/apache2)
* -e LOG_NAME=...(default to 0js-v3_scielo_org)

The pkp-ojs container expect a mysql container to work. So, you need to run mysql container first. Don't forget to specify a container name to mysql to work with --link. The link option create a relationship with each other.

```
docker run --name <some-mysql> \
           -e MYSQL_ROOT_PASSWORD=<password>  \
           -e MYSQL_USER=<user> \
           -e MYSQL_PASSWORD=<password> \
           -d mysql
```

The instruction above creates container setting mysql root password and creates other user and its respective password.

After create mysql container you can can run the omp container.

**Sample**
```
$ docker run --name mysql \
              -e MYSQL_ROOT_PASSWORD=ojs  \
              -e MYSQL_USER=ojs \
              -e MYSQL_PASSWORD=ojs \
              -d mysql
```
```
$ docker run -p 80:80 \
             -e OJS_DB_HOST=mysql \
             -e OJS_DB_USER=root \
             -e OJS_DB_PASSWORD=ojs \
             --link mysql:mysql \
             -d infrascielo/pkp-ojs:3.0b1
```

Important points
================
If you would like to save logs it is necessary to specify volume when run containers. Follow example:
```
$ docker run -p 80:80 \
             -e OJS_DB_HOST=mysql \
             -e OJS_DB_USER=root \
             -e OJS_DB_PASSWORD=ojs \
             -e APACHE_LOG_DIR=/var/log/apache2 \
             -e LOG_NAME=0js-v3_scielo_org \
             -v /var/www/apache2:/var/www/apache2 \
             --link mysql:mysql \
             -d infrascielo/pkp-ojs:3.0b1
```
* The parameter **-v /var/www/apache2:/var/www/apache2** allows to mount /var/www/apache2 to save logs outside the container
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

To work with --link you must have to run a mysql container
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
             -e OMP_DB_HOST=mysql \
             -e OMP_DB_USER=root \
             -e OMP_DB_PASSWORD=omp \
             --link mysql:mysql \
             -d infrascielo/pkp-ojs
```
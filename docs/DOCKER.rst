Containerized NIPAP
=====================
So as this is getting to be some pretty old code, using Python 2.6, you may want
to run it containerized, in order to keep your OS current while still being able
to serve this brilliant IPAM for years to come.
To this end, containerized versions of the IPAM subsystems can go a long way.

Using public images
-------------------
You'll need at least 3 containers to run NIPAP with a UI:
https://hub.docker.com/r/nipap/postgres-ip4r
https://hub.docker.com/r/nipap/nipapd
https://hub.docker.com/r/nipap/nipap-www

Building your own from scratch
------------------------------
docker build --build-arg BUILDID=$(date +%s) -t net-docker-reg.vestas.net/ubuntu-xenial-nipap:latest -f Dockerfile.base .
docker build --build-arg VERSION=0.29.8 --build-arg BUILDID=$(date +%s) -t net-docker-reg.vestas.net/nipapd:0.29.8 -f Dockerfile.nipapd .
docker build --build-arg VERSION=0.29.8 --build-arg BUILDID=$(date +%s) -t net-docker-reg.vestas.net/nipap-www:0.29.8 -f Dockerfile.www .
docker build --build-arg VERSION=0.29.8 --build-arg BUILDID=$(date +%s) -t net-docker-reg.vestas.net/nipap-whoisd:0.29.8 -f Dockerfile.whoisd .

docker push net-docker-reg.vestas.net/ubuntu-xenial-nipap:latest
docker push net-docker-reg.vestas.net/nipapd:0.29.8
docker push net-docker-reg.vestas.net/nipap-www:0.29.8
docker push net-docker-reg.vestas.net/nipap-whoisd:0.29.8


Using a compose file
--------------------
Below is an example compose snip which will maintain the database in $dir/pgsql::

    version: '3.2'
    services:
      nipap-db:
        image:  nipap/postgres-ip4r
        volumes:
          - ./${dir}/pgsql:/var/lib/postgresql/data
        ports:
          - "5432:5432"
        environment:
          - PGDATA=/var/lib/postgresql/data/pgdata
          - POSTGRES_USER=nipap
          - POSTGRES_PASSWORD=S3cretDBPas5
          - POSTGRES_DB=nipap

      nipapd:
        image: nipap/nipapd:master
        depends_on:
          - nipap-db
        links:
          - nipap-db
        ports:
          - "1337:1337"
        environment:
          - DB_USERNAME=nipap
          - DB_PASSWORD=S3cretDBPas5
          - DB_HOST=nipap-db
          - DB_NAME=nipap
          - NIPAP_USERNAME=www
          - NIPAP_PASSWORD=nipapP4ssw0rd

      nipap-www:
        image: nipap/nipap-www
        links:
          - nipapd
        ports:
          - "8989:80"
        environment:
          - NIPAPD_USERNAME=www
          - NIPAPD_PASSWORD=nipapP4ssw0rd
          - WWW_USERNAME=www
          - WWW_PASSWORD=nipapP4ssw0rd

So if you start NIPAP using::

    export dir=unittests && docker-compose -f nipap-compose.yaml up -d
    export dir=etc_nipap && docker-compose -f etc_nipap/compose.yaml up

Then it will use ./unittestes/pgsql to store the database.


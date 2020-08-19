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
Please see the compose example in compose_dir, as this illustrates how to run a NIPAP stack.

In this example, startup.sh (bash script) will:
    1. check for presence of a config file
    2. add an empty db for local nipap users, if absent - to be mounted by containers
    3. startup the compose file, offering the folder housing the script to store: pgsql db, www logs & local user db mentioned above.

Output::

    compose_dir stsmr$ bash startup.sh
    Creating network "nipap_default" with the default driver
    Creating nipap_nipap-db_1 ... done
    Creating nipap_nipapd_1   ... done
    Creating nipap_nipap-www_1    ... done
    Creating nipap_nipap-whoisd_1 ... done
    Attaching to nipap_nipap-db_1, nipap_nipapd_1, nipap_nipap-www_1, nipap_nipap-whoisd_1
    nipapd_1        | wait-for-it.sh: waiting 60 seconds for nipap-db:5432
    nipap-www_1     | AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 192.168.240.4. Set the 'ServerName' directive globally to suppress this message
    nipap-db_1      | 2020-08-19 11:50:15.214 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
    nipap-db_1      | 2020-08-19 11:50:15.214 UTC [1] LOG:  listening on IPv6 address "::", port 5432
    nipap-db_1      | 2020-08-19 11:50:15.231 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
    nipap-db_1      | 2020-08-19 11:50:15.309 UTC [24] LOG:  database system was shut down at 2020-08-19 11:49:24 UTC
    nipap-db_1      | 2020-08-19 11:50:15.342 UTC [1] LOG:  database system is ready to accept connections
    nipap-db_1      | 2020-08-19 11:50:15.610 UTC [31] LOG:  incomplete startup packet
    nipapd_1        | wait-for-it.sh: nipap-db:5432 is available after 4 seconds
    nipapd_1        | Creating user 'www'
    nipapd_1        | UNIQUE constraint failed: user.username
    nipapd_1        | Starting nipap daemon..


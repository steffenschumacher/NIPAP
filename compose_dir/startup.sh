
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
CONF=nipap.conf.dist
if [ ! -f "$CONF" ]; then
    echo "Missing config file in $DIR: $CONF"
    exit
fi

SQLITEDB=local_auth.db
if [ ! -f "$DIR/$SQLITEDB" ]; then
    echo "Adding empty sqlite db for local users, to be mounted by containers.."
    touch $DIR/$SQLITEDB
fi

export dir=$DIR && docker-compose --project-directory ../ -f $DIR/compose.yaml up


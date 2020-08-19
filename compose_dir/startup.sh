
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONF=nipap.conf.dist
if [ ! -f "$DIR/$CONF" ]; then
    echo "Missing config file in $DIR: $CONF"
    exit
fi

SQLITEDB=local_auth.db
if [ ! -f "$DIR/$SQLITEDB" ]; then
    echo "Adding empty sqlite db for local users, to be mounted by containers.."
    touch $DIR/$SQLITEDB
fi
cd ..
echo "export dir=$DIR && docker-compose --project-directory ./ -f $DIR/compose.yaml down"
export dir=$DIR && docker-compose --remove-orphans --project-directory ./ -f $DIR/compose.yaml up
export dir=$DIR && docker-compose --project-directory ./ -f $DIR/compose.yaml down


#!/bin/sh
set -e -x

export GOPATH=$(pwd)
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

echo "Starting $DB..."
case "$DB" in
  mysql)
    mv /var/lib/mysql /var/lib/mysql-src
    mkdir /var/lib/mysql
    mount -t tmpfs -o size=256M tmpfs /var/lib/mysql
    mv /var/lib/mysql-src/* /var/lib/mysql/

    service mysql start
    ;;
  postgresql)
    export PATH=$( echo /usr/lib/postgresql/*/bin ):$PATH

    mkdir /tmp/postgres
    mount -t tmpfs -o size=512M tmpfs /tmp/postgres
    mkdir /tmp/postgres/data
    chown postgres:postgres /tmp/postgres/data
    export PGDATA=/tmp/postgres/data

    su postgres -c '
      export PATH=$( echo /usr/lib/postgresql/*/bin ):$PATH
      export PGDATA=/tmp/postgres/data
      export PGLOGS=/tmp/log/postgres
      mkdir -p $PGDATA
      mkdir -p $PGLOGS
      initdb -U postgres -D $PGDATA
      pg_ctl start -w -l $PGLOGS/server.log -o "-N 400"
    '
    ;;
  memory)
    echo "Memory DB Noop"
    ;;
  *)
    echo "Usage: DB={mysql|postgresql|memory} $0 {commands}"
    exit 1
esac

cd src/github.com/cloudfoundry/config-server

bin/test-integration $DB

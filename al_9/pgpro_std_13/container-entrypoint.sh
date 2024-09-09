#!/usr/bin/env bash

chown -R postgres:postgres /_data/pg_backup
chmod -R 666 /_data/pg_backup
chown -R postgres:postgres /_data/pg_data
chmod -R 700 /_data/pg_data

set -e

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    pg_ctl initdb -D $PGDATA -o "--locale=$LANG --lc-collate=$LANG"
    printf "host    all             all             all                     md5\n" >> $PGDATA/pg_hba.conf
fi

exec "$@"

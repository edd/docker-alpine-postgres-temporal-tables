#!/bin/sh
chown -R postgres "$PGDATA"

if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    mkdir -p "$PGDATA"/ssl && \
    cd "$PGDATA"/ssl && \
    openssl req -new -newkey rsa:1024 -days 365000 -nodes -x509 -keyout server.key -subj "/CN=PostgreSQL" -out server.crt
    chmod 600 server.*
    chown postgres:postgres server.*
    chown -R postgres:postgres "$PGDATA"../ssl

    echo "local all all   peer" >> "$PGDATA"/pg_hba.conf
    echo "hostssl   all           all   0.0.0.0/0   md5" >> "$PGDATA"/pg_hba.conf
    echo "ssl = on" >> "$PGDATA"/postgresql.conf
    echo "ssl_key_file = '$PGDATA/ssl/server.key'" >> "$PGDATA"/postgresql.conf
    echo "ssl_ciphers = 'DEFAULT:!LOW:!EXP:!MD5:@STRENGTH'" >> "$PGDATA"/postgresql.conf
    echo "ssl_cert_file = '$PGDATA/ssl/server.crt'" >> "$PGDATA"/postgresql.conf

    : ${POSTGRES_USER:="postgres"}
    : ${POSTGRES_DB:=$POSTGRES_USER}

    if [ "$POSTGRES_PASSWORD" ]; then
      pass="PASSWORD '$POSTGRES_PASSWORD'"
      authMethod=md5
    else
      echo "==============================="
      echo "!!! Use \$POSTGRES_PASSWORD env var to secure your database !!!"
      echo "==============================="
      pass=
      authMethod=trust
    fi
    echo


    if [ "$POSTGRES_DB" != 'postgres' ]; then
      createSql="CREATE DATABASE $POSTGRES_DB;"
      echo $createSql | gosu postgres postgres --single -jE
      echo
    fi

    if [ "$POSTGRES_USER" != 'postgres' ]; then
      op=CREATE
    else
      op=ALTER
    fi

    userSql="$op USER $POSTGRES_USER WITH SUPERUSER $pass;"
    echo $userSql | gosu postgres postgres --single -jE
    echo

    # internal start of server in order to allow set-up using psql-client
    # does not listen on TCP/IP and waits until start finishes
    gosu postgres pg_ctl -D "$PGDATA" \
        -o "-c listen_addresses=''" \
        -w start

    echo
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)  echo "$0: running $f"; . "$f" ;;
            *.sql) echo "$0: running $f"; psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < "$f" && echo ;;
            *)     echo "$0: ignoring $f" ;;
        esac
        echo
    done

    gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop
fi

exec gosu postgres "$@"

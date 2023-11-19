#!/usr/bin/env bash

# Wait until db is ready
until mysql -hdb -uroot -p"${MARIADB_ROOT_PASSWORD}" --silent -e "SELECT 1;" >/dev/null; do
    echo "Waiting for database to start"
    sleep 5
done

# Apply migrations
mix ecto.migrate

# Start server
exec mix phx.server

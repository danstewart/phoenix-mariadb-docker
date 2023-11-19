#!/usr/bin/env bash


# Wait until db is ready
until mysql -hdb -uroot -p"${MARIADB_ROOT_PASSWORD}" --silent -e "SELECT 1;" >/dev/null; do
    echo "Waiting for database to start"
    sleep 5
done

# Create the database if it doesn't already exist
docker-compose exec db mariadb -h127.0.0.1 -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS '${DATABASE}'"

# Apply migrations
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs

# Build assets
cd assets && npm rebuild node-sass && cd ..

# Start server
exec mix phx.server

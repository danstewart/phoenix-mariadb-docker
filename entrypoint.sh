#!/usr/bin/env bash

cd phoenix

# Wait until mySQL is ready 
until mysql -hdb -uroot -p${MYSQL_ROOT_PASSWORD} --silent -e "SELECT 1;" >/dev/null; do
    echo "Waiting for database to start"
    sleep 5
done

# function does_db_exist() {
#     database_name="$1"
#     docker-compose exec db mysql -h127.0.0.1 -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${database_name}'"
#     return 0
# }

# # Create, migrate, and seed database if it doesn't exist.
# if [[ does_db_exist ${DATABASE} ]]; then
#   echo "Database ${DATABASE} does not exist. Creating..."
#   mix ecto.create
#   mix ecto.migrate
#   mix run priv/repo/seeds.exs
#   echo "Database $DATABASE created."
# fi

exec mix phx.server

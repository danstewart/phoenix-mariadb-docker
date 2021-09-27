#!/usr/bin/env bash

set -e

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --app) app=$2; shift ;;
        -h|--help) help=1 ;;
        --) shift; break ;;
    esac

    shift
done

if [[ -z $app || $help == 1 ]]; then
    echo "Usage: ./init.sh --app <app_name>"
    echo ""
    echo "Will initialise a new phoenix application and start the container on http://localhost:4000"

    exit 0
fi

# TODO: Generate a .env file
# ...

echo "Building containers..."
docker-compose build --quiet >/dev/null 2>&1

echo "Generating new phoenix app..."
echo y | docker-compose run app mix phx.new . --app "$app" --database mysql >/dev/null 2>&1
docker-compose run app mix deps.get >/dev/null 2>&1

# Tweak the dev.exs config to read from the environment file
echo "Rejigging the config..."
perl -p -i -e 's/username: .*,/username: System.get_env("MYSQL_USER"),/' src/config/dev.exs
perl -p -i -e 's/password: .*,/password: System.get_env("MYSQL_PASSWORD"),/' src/config/dev.exs
perl -p -i -e 's/database: .*,/database: System.get_env("DATABASE_NAME"),/' src/config/dev.exs
perl -p -i -e 's/hostname: .*,/hostname: "db",/' src/config/dev.exs
perl -p -i -e 's/ip: \{127, 0, 0, 1\}/ip: {0, 0, 0, 0}/' src/config/dev.exs

echo "Initialising database..."
docker-compose run app mix ecto.create >/dev/null 2>&1

echo "Starting container..."
docker-compose up -d --build app >/dev/null 2>&1

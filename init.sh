#!/usr/bin/env bash

set -e

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --app) app=$2; shift ;;
        -v|--verbose) verbose=1 ;;
        -h|--help) help=1 ;;
        --) shift; break ;;
    esac

    shift
done

if [[ -z $app || $help == 1 ]]; then
    echo "Usage: ./init.sh --app <app_name> [--verbose] [--help]"
    echo ""
    echo "Will initialise a new phoenix application and start the container on http://localhost:4000"
    echo "  --app:     The name of the phoenix app"
    echo "  --verbose: Display all command output"
    echo "  --help:    Display this help text and exit"

    exit 0
fi

output=/dev/null
if [[ -n $verbose && $verbose == 1 ]]; then
    output=/dev/stdout
fi

function generate_password {
    < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32
}

# Rejig the compose file
sed -i "s/{{ app }}/$app/g" docker-compose.yml

echo "Generating .env file..."
[[ -f .env ]] && rm -f .env
touch .env
echo "MARIADB_DATABASE=${app}" >> .env
echo "MARIADB_USER=app" >> .env
echo "MARIADB_PASSWORD=$(generate_password)" >> .env
echo "MARIADB_ROOT_PASSWORD=$(generate_password)" >> .env
echo "MARIADB_ROOT_HOST=%" >> .env

echo "Building containers..."
docker compose build >$output 2>&1

echo "Generating new phoenix app..."
docker compose run app bash -c "echo y | mix phx.new . --app '$app' --database mysql" >$output 2>&1

# Tweak the dev.exs config to read from the environment file
echo "Rejigging the config..."
perl -p -i -e 's/username: .*,/username: System.get_env("MARIADB_USER"),/' src/config/dev.exs
perl -p -i -e 's/password: .*,/password: System.get_env("MARIADB_PASSWORD"),/' src/config/dev.exs
perl -p -i -e 's/database: .*,/database: System.get_env("MARIADB_DATABASE"),/' src/config/dev.exs
perl -p -i -e 's/hostname: .*,/hostname: "db",/' src/config/dev.exs
perl -p -i -e 's/ip: \{127, 0, 0, 1\}/ip: {0, 0, 0, 0}/' src/config/dev.exs

echo "Initialising database..."
docker compose run app mix ecto.create >$output 2>&1

echo "Starting container..."
docker compose up -d --build app >$output 2>&1

# Set up .gitignore
rm -f .gitignore
echo "src/_build/" >> .gitignore
echo "src/deps/" >> .gitignore
echo ".env" >> .gitignore

echo -e "\nDone! Your phoenix app should now be running on http://localhost:4000"

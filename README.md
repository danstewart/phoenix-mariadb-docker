# Phoenix & MySQL Docker Bootstrap

:warning: This is a work in progress and is not suitable for real usage yet

## Get Started

```shell
# Build your containers
docker-compose build

# Generate the app
docker-compose run app mix phx.new . --app {project_name} --database mysql
```

Now edit `src/config/dev.exs` to contain:
```
config :demo, Demo.Repo,
  username: System.get_env("MYSQL_USER"),
  password: System.get_env("MYSQL_PASSWORD"),
  database: System.get_env("MYSQL_DATABASE"),
  hostname: "db",
```

and
```
config :demo, DemoWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
```

Then initialise the database and start the app
```
# Configure and start the database container
echo "MYSQL_ROOT_PASSWORD='$(openssl rand -hex 32)'" > .env
docker-compose up -d db

# Initialise the database (once the container has started)
docker-compose run app mix ecto.create

# Start the app on http://localhost:4000
docker-compose up app
```

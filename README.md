# Phoenix & MariaDB Docker Bootstrap

## Get Started
On first time set up run the `init.sh` script to create a new phoenix application, initialise the database and start the app on http://localhost:4000
```shell
app="my-app-name"
git clone git@github.com:danstewart/phoenix-mariadb-docker.git "$app"
./init.sh --app "$app"
```

The container will mount the `./src` folder to the container so any changes made will be picked up by the container and the phoenix hot reloader.  

# Phoenix & MySQL Docker Bootstrap

:warning: This is a work in progress and is not suitable for real usage yet

## Get Started
On first time set up run the `init.sh` script to create a new phoenix application, initialise the database and start the app on http://localhost:4000
```shell
./init.sh --app <app_name>
```

The container will mount the `./src` folder to the container so any changes made will be picked up by the container and the phoenix hot reloader.  

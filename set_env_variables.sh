#!/bin/bash

# Function to update the fpm configuration to make the service environment variables available
function setEnvironmentVariable() {
 
    if [ -z "$2" ]; then
        echo "Environment variable '$1' not set."
        return
    fi
 
     # Add variable
    echo "env[$1] = $2" >> /etc/php/7.3/fpm/pool.d/www.conf
}

echo "Setting environment variables"
for _curVar in `env | grep LIME_ | awk -F = '{print $1}'`; do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    echo ${_curVar}
    setEnvironmentVariable ${_curVar} ${!_curVar}
done
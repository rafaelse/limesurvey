#!/bin/bash

# Script created to run nginx along with PHP-FPM based on the example by Docker

echo "Checking if installation is required"
if [ -f "/var/www/limesurvey/application/config/config.php" ]; then

	echo "config.php was provided: installation is required"

	# Checks if the host is listening on port 5432
	nc -zv db 5432 > /dev/null 2>&1
	status=$?
	echo "Checking if DB server is available"
	while [ $status -ne 0 ]; do
		echo "DB server not available yet"
		sleep 2
		nc -zv db 5432 > /dev/null 2>&1
		status=$?
	done
	echo "DB server available"

	echo "Waiting to install limesurvey"
	sleep 5 # Wait for DBMS to be initialize the database
	psql -h db -U limesurvey -c 'SELECT count(*) FROM lime_users' > /dev/null 2>&1
	status=$?
	if [ $status -ne 0 ]; then
		echo "Installing Limesurvey"
		php application/commands/console.php installfromconfig application/config/config.php
		status=$?
		if [ $status -ne 0 ]; then
			echo "Failed to install Limesurvey: $status"
			exit $status
		fi
		echo "Limesurvey installed!"
	else
		echo "Limesurvey is already installed"
	fi
else
	echo "config.php was not provided: installation is not required"
fi

# Starts NGINX
/usr/sbin/nginx
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start nginx: $status"
	exit $status
fi

# Start PHP-FPM
/usr/sbin/php-fpm7.3
status=$?
if [ $status -ne 0 ]; then
	echo "Failed to start php-fpm: $status"
	exit $status
fi

while sleep 60; do
  ps aux | grep nginx | grep -v grep
  NGINX_STATUS=$?
  ps aux | grep php-fpm | grep -v grep
  PHPFPM_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $NGINX_STATUS -ne 0 -o $PHPFPM_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
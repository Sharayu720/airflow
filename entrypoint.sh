#!/bin/bash

# Update and install necessary packages
sudo yum update -y
sudo yum install -y python3 gcc gcc-c++ libpq-dev nginx

# Start Nginx and enable it to start on boot
sudo systemctl start nginx
sudo systemctl enable nginx

# Activate the Airflow virtual environment
source ~/airflow_env/bin/activate

# Install required Python dependencies (Airflow and other packages)
pip install -r ~/airflow-setup/requirements.txt

# Initialize Airflow database if it hasn't been initialized already
if [ ! -f "$AIRFLOW_HOME/airflow.db" ]; then
    airflow db init
fi

# Start Airflow webserver and scheduler as background processes
airflow webserver -D  # Starts the webserver in the background
airflow scheduler -D  # Starts the scheduler in the background

# Ensure Nginx is running as a reverse proxy
echo "Airflow and Nginx are now set up and running."

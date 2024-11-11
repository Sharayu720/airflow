#!/bin/bash

# Install Nginx if not installed
sudo yum install -y nginx

# Start and enable Nginx to start on boot
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Python dependencies and setup Airflow environment (assuming it's already done)
pip3 install virtualenv

# Activate the Airflow virtual environment
source ~/airflow_env/bin/activate

# Install the required Python packages (already exists in your repo)
pip install -r ~/airflow-setup/requirements.txt

# Initialize Airflow database if it hasn't been initialized already
if [ ! -f "$AIRFLOW_HOME/airflow.db" ]; then
    airflow db init
fi

# Ensure the Nginx service is started and enabled
sudo systemctl start nginx
sudo systemctl enable nginx

# Optionally start Airflow webserver and scheduler as background processes
airflow webserver -D
airflow scheduler -D

echo "Airflow and Nginx are set up and running."


#!/bin/bash

# Update and install any required packages
sudo yum update -y
sudo yum install -y python3 gcc gcc-c++ libpq-dev

# Install virtualenv if not installed
pip3 install virtualenv

# Set up Airflow environment (if not done already)
AIRFLOW_HOME=~/airflow
AIRFLOW_VENV=~/airflow_env

# Create the virtual environment if it doesn't exist
if [ ! -d "$AIRFLOW_VENV" ]; then
    python3 -m venv $AIRFLOW_VENV
fi

# Activate the virtual environment
source $AIRFLOW_VENV/bin/activate

# Install required Python dependencies
pip install -r ~/airflow-setup/requirements.txt

# Initialize Airflow database if it hasn't been initialized already
if [ ! -f "$AIRFLOW_HOME/airflow.db" ]; then
    airflow db init
fi

# Start the Airflow webserver and scheduler
airflow webserver -D  # Starts the webserver as a daemon (in background)
airflow scheduler -D  # Starts the scheduler as a daemon (in background)

echo "Airflow is set up and running."

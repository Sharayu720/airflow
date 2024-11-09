
#!/bin/bash

# Install system dependencies
sudo apt-get update
sudo apt-get install -y python3-pip python3-dev build-essential libpq-dev

# Install Airflow (in a virtual environment)
python3 -m venv airflow-env
source airflow-env/bin/activate

# Install Airflow and other dependencies
pip install apache-airflow==2.10.1

# Initialize the Airflow database (this will create the airflow.cfg file)
airflow db init

# Optionally, start Airflow webserver and scheduler
airflow webserver -D
airflow scheduler -D

echo "Airflow installed and running."

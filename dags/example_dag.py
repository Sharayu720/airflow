from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from datetime import datetime

# Define the default_args dictionary
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
}

# Define the DAG
dag = DAG(
    'example_dag', 
    default_args=default_args, 
    description='An example DAG',
    schedule_interval='@daily',  # Can also use cron expressions
    catchup=False,
)

# Define the tasks
start_task = DummyOperator(
    task_id='start', 
    dag=dag,
)

end_task = DummyOperator(
    task_id='end', 
    dag=dag,
)

# Set the task dependencies
start_task >> end_task

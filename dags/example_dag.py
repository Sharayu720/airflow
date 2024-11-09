
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from datetime import datetime

# Define the DAG
dag = DAG(
    'example_dag',
    description='A simple example DAG',
    schedule_interval='@daily',  # Run daily
    start_date=datetime(2023, 11, 9),
    catchup=False,
)

# Define tasks
start_task = DummyOperator(
    task_id='start_task',
    dag=dag,
)

end_task = DummyOperator(
    task_id='end_task',
    dag=dag,
)

# Set task dependencies
start_task >> end_task

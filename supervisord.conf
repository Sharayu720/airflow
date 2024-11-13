[program:airflow-webserver]
command=/home/ubuntu/airflow_venv/bin/airflow webserver
autostart=true
autorestart=true
stderr_logfile=/var/log/airflow/webserver.err.log
stdout_logfile=/var/log/airflow/webserver.out.log

[program:airflow-scheduler]
command=/home/ubuntu/airflow_venv/bin/airflow scheduler
autostart=true
autorestart=true
stderr_logfile=/var/log/airflow/scheduler.err.log
stdout_logfile=/var/log/airflow/scheduler.out.log

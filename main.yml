---
- name: Setup Airflow and Nginx with Reverse Proxy
  hosts: your-ec2-instance  # Target EC2 host (or group of hosts)
  become: yes  # This allows privilege escalation (root permissions)

  tasks:

    # Install Nginx
    - name: Install Nginx if not installed
      yum:
        name: nginx
        state: present

    # Ensure Nginx is started and enabled to start on boot
    - name: Ensure Nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: yes

    # Upload the nginx configuration file (make sure nginx.conf is configured)
    - name: Upload nginx configuration
      copy:
        src: nginx.conf  # Path to your custom Nginx config file
        dest: /etc/nginx/nginx.conf  # Replace the default config with your own
        owner: root
        group: root
        mode: '0644'

    # Reload Nginx to apply the new configuration
    - name: Reload Nginx to apply the configuration
      service:
        name: nginx
        state: reloaded

    # Install Python dependencies (Airflow and other packages)
    - name: Install Airflow dependencies
      pip:
        requirements: /home/ec2-user/airflow-setup/requirements.txt
        virtualenv: /home/ec2-user/airflow_env

    # Initialize the Airflow database if it hasn't been initialized
    - name: Initialize the Airflow database
      command: airflow db init
      args:
        creates: /home/ec2-user/airflow/airflow.db  # Only runs if airflow.db doesn't exist

    # Start Airflow webserver and scheduler
    - name: Start Airflow webserver
      command: airflow webserver -D
      args:
        creates: /home/ec2-user/airflow/airflow.db  # Only runs if webserver is not already started

    - name: Start Airflow scheduler
      command: airflow scheduler -D
      args:
        creates: /home/ec2-user/airflow/airflow.db  # Only runs if scheduler is not already started

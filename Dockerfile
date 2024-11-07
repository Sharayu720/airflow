FROM ubuntu:20.04

# Build Arguments
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AIRFLOW_VERSION=2.10.1  # Set Airflow version

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV AWS_DEFAULT_REGION=us-east-1
ENV AIRFLOW_HOME=/root/airflow

# Install system dependencies and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils \
        vim \
        unzip \
        git \
        default-jre \
        gcc \
        g++ \
        libpq-dev \
        freetds-bin \
        krb5-user \
        ldap-utils \
        libsasl2-2 \
        libsasl2-modules \
        libssl1.1 \
        locales \
        lsb-release \
        sasl2-bin \
        sqlite3 \
        unixodbc \
        postgresql \
        postgresql-contrib \
        python3-pip \
        python3.8-venv \
        net-tools \
        jq \
        parallel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install and configure PostgreSQL
USER postgres
RUN /etc/init.d/postgresql start && \
    psql -c "CREATE DATABASE airflow_db;" && \
    psql -c "CREATE USER airflow_user WITH PASSWORD 'airflow_pass';" && \
    psql -c "GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;"

USER root

# Copy necessary files into the container
COPY input.txt /input.txt
COPY installairflow.sh /installairflow.sh
COPY airflow.cfg /airflow.cfg
COPY requirement.txt /requirement.txt
COPY entrypoint.sh /entrypoint.sh

# Make scripts executable
RUN chmod +x /installairflow.sh /entrypoint.sh

# Read Airflow version from input.txt (if dynamic)
RUN airflow_link="$(awk 'NR==4' /input.txt)" && echo $airflow_link

# Install Airflow and dependencies
RUN ./installairflow.sh && \
    pip install "apache-airflow==$AIRFLOW_VERSION" --no-cache-dir && \
    pip install -r /requirement.txt --no-cache-dir

# AWS Configuration
RUN aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID && \
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY && \
    aws configure set default.region us-east-1

# S3 sync or download from S3
RUN aws s3 cp s3://idms-2722-airflow-release/$(aws s3 ls s3://idms-2722-airflow-release/ | sort | tail -n 1 | awk '{print $NF}') variables.json . && \
    aws s3 cp s3://idms-2722-airflow-release/$(aws s3 ls s3://idms-2722-airflow-release/ | sort | tail -n 1 | awk '{print $NF}') connections.json . 

# Set up Airflow database
RUN airflow db init

# Create necessary directories
RUN mkdir -p $AIRFLOW_HOME/dags

# Copy configuration and entrypoint script
RUN cp /airflow.cfg /root/airflow/airflow.cfg

# Set entrypoint
ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]

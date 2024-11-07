
name: Build Docker Image and Push to AWS ECR

on:
  push:
    branches:
      - main
    paths:
      - input.txt

env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  ECR_REGISTRY: 250245842722.dkr.ecr.us-east-1.amazonaws.com/airflow-dev
  AIRFLOW_VERSION: '2.10.1'  # Set the target Airflow version here

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v2
      
    - name: Read Input file
      run: |
        echo "previous_version=$(cat input.txt | awk 'NR==1')" >> $GITHUB_ENV
        echo "previous_install=$(cat input.txt | awk 'NR==2')" >> $GITHUB_ENV
        echo "upgrade_version=$(cat input.txt | awk 'NR==3')" >> $GITHUB_ENV
        echo "upgrade_install=$(cat input.txt | awk 'NR==4')" >> $GITHUB_ENV
        cat input.txt | awk 'NR==1'
        cat input.txt | awk 'NR==2'
        cat input.txt | awk 'NR==3'
        cat input.txt | awk 'NR==4'
        
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
        
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build, tag, and push image to Amazon ECR
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: airflow-dev
        AIRFLOW_VERSION: ${{ env.AIRFLOW_VERSION }}
        
      run: |
        # Pull the existing image from ECR
        docker pull 250245842722.dkr.ecr.us-east-1.amazonaws.com/airflow-dev:latest
        
        # Tag the pulled image with the previous version
        docker tag 250245842722.dkr.ecr.us-east-1.amazonaws.com/airflow-dev:latest 250245842722.dkr.ecr.us-east-1.amazonaws.com/airflow-dev:${{env.previous_version}}
        
        # Build new image based on Airflow version defined in the env
        docker build \
          --build-arg AIRFLOW_VERSION=${{ env.AIRFLOW_VERSION }} \
          --build-arg AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
          --build-arg AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
          -t ${{env.upgrade_version}} .

        docker image ls  # Verify the new image is built

        # Tag the newly built image as 'latest' for pushing to ECR
        docker tag ${{env.upgrade_version}}:latest 250245842722.dkr.ecr.us-east-1.amazonaws.com/airflow-dev:latest
        
        # Verify the tag is applied
        docker image ls
        
        # Optionally, delete the previous 'latest' image from ECR (cleanup)
        aws ecr batch-delete-image --repository-name airflow-dev --image-ids imageTag=latest

        # Push the newly built image to ECR
        docker push 250245842722.dkr.ecr.us-east-1.amazonaws.com/airflow-dev:latest
        docker push 250245842722.dkr.ecr.us-east-1.amazonaws.com/airflow-dev:${{env.previous_version}}


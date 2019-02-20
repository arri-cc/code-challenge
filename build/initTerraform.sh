#!/bin/bash
#check if terraform backend is configured
if [ ! -f ../infrastructure/terraform/backend.config ]; then
    cp ../infrastructure/terraform/backend.config.sample ../infrastructure/terraform/backend.config
    read -p "The terraform s3 backend has not been configured, press ENTER to configure"
    vim ../infrastructure/terraform/backend.config
    echo "terraform backend.config configured, initializing..."
    pushd ../infrastructure/terraform
    terraform init --backend-config=backend.config
    popd
else
    echo "terraform backend.config found"
fi

#check if terraform backend is configured
if [ ! -f ../infrastructure/terraform/terraform.tfvars ]; then
    cp ../infrastructure/terraform/terraform.tfvars.sample ../infrastructure/terraform/terraform.tfvars
    read -p "The terraform.tfvars has not been configured, press ENTER to configure"
    vim ../infrastructure/terraform/terraform.tfvars
    echo "terraform.tfvars was successfully configured"
else
    echo "terraform terraform.tfvars found"
fi
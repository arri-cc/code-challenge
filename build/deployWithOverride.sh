#!/bin/bash
cd ../infrastructure/packer
packer build -var override_health_check=yes webserver.json
cd ../terraform
terraform plan -out=aws.plan
terraform apply aws.plan
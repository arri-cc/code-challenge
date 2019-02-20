#!/bin/bash
set -eou pipefail
if [ -z "$1" ]; then
    echo "ami version is required for this build"
    echo "try again with the new version number e.g. ./deployWithDefaults.sh \"0.3.0\""
    exit 1
fi

AMI_VERSION=$1

#ensure terraform is configured
source ./initTerraform.sh

#run packer
cd ../infrastructure/packer
packer build -var override_health_check=yes -var ami_version=$AMI_VERSION webserver.json

#run terraform
cd ../terraform
terraform plan -out=aws.plan
terraform apply aws.plan
#!/bin/bash
set -eou pipefail
pushd ../infrastructure/terraform
terraform destroy
popd
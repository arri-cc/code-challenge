# Description

This project provides a solution for the `ops` code challenge by Lucky Day.  I set out to solve the following challenges:

- Orchestrate an HA cloud infrastructure in AWS with Terraform
- Configure the immutable AMIs with Ansible
- Configure and enforce SSL via an Elastic Load Balancer
- Provide a simple way to configure and deploy new versions of the app without downtime, to include swapping the health check message.



## Requirements

There are a few software and configuration requirements that must be met in order to deploy a working version of this solution.

### Software

| Software                                                     | Version | Purpose                                          |
| ------------------------------------------------------------ | ------- | ------------------------------------------------ |
| [Ansible](https://docs.ansible.com/ansible/2.5/installation_guide/intro_installation.html) | 2.7     | Automated configuration of the compute resources |
| [Terraform](https://www.terraform.io/intro/getting-started/install.html) | 0.11.11 | Automated infrastructure orchestration           |
| [dotnet core sdk](https://www.microsoft.com/net/download)    | 2.1.5   | To compile the sample application                |

### AWS Resources

- A Route53 DNS Zone 
- An S3 Bucket to manage terraform state and logs

### Configuration

To reduce the need to manage secrets, `AWS` and `ssh` credentials and keys are required to be installed in the standard user directories.

- For the sake of simplicity, on your workstation an AWS credential file is expected here `~/.aws/credential` with the `default` profile configured to use the correct credentials for the target environment
- An ssh key with a name and public key that matches what's configured in the Terraform variable `var.ssh_public_key` in the variables file `infrastructure/terraform/variables.tf` as well as the ansible playbook `infrastructure/ansible/aws.yml`.  For this example `~/.ssh/luckyday_id_rsa` and the contents of `~/.ssh/luckyday_id_rsa.pub` are used.

## TL;DR;  How to run it

Here's the steps to fully orchestrate and configure the solution, assuming all of the prerequisites have been met.

1. Build and publish a new image: `cd infrastrastructure/packer && packer build -var ami_version=0.3.2 webserver.json`  _please note:_ the `ami_version` has to be unique, and specifying it here overrides the value in the `webserver.json` file, which is suitable for a CI/CD process.
2. To configure the `s3 backend` for terraform, chand to the terraform directory and make a copy of the sample backend config file `cd ../terraform && cp backend.config.sample backend.config` and configure the values for the target s3 bucket and region.
3. Now initialize terraform: `terraform init --backend-config=backend.config`
4. Next create a terraform plan: `terraform plan -out aws.plan`
5. After reviewing the plan, you can apply it to deploy the entire solution: `terraform apply aws.plan`
6. Terraform will configure the infrastructure.

You now have a fully configured, highly available web application.

## A breakdown of how each goal was accomplished

I'd like to provide more informations on the choices I made while performing this work.

### Orchestrate an HA cloud infrastructure in AWS with Terraform

![](readme_images/ha-web-aws.png)

#### The following was configured:

- 1 Amazon Route 53 for DNS and automated SSL Verification
- 1 AWS Internet Gateway for the VPC
- 1 AWS ELB for load balancing across instances
- 1 VPC with 3 subnets, each in a different availability zone
- 3 AWS Instances, each deployed to different availability zones via an Auto Scaling Group

Subnets:

| Network Address  | Broadcast Address | Availability Zone |
| ---------------- | ----------------- | ----------------- |
| 10.10.220.0/24   | 10.10.220.255     | n/a               |
| 10.10.220.0/26   | 10.10.220.63      | us-west-2a        |
| 10.10.220.64/26  | 10.10.220.127     | us-west-2b        |
| 10.10.220.128/26 | 10.10.220.191     | us-west-2c        |

### Configure the application servers with Ansible

Packer was used to configure immutable AMIs to simplify how the ASG provisions new ec2 instances.

Key aspects:

- Base AMI is based on centos7
- The `ansible-local` provisioner was used
- The sample application was made with `dotnet core 2.1`, which is compiled as a part of the ami provisioning process

### Configure and enforce SSL

- Leveraged Terraform to request, verify, and configure an SSL certificate at the ELB
- Configured nginx to enforce SSL by inspecting the forwarding HTTP headers.


### Provide an easy way to deploy updates

I've provided the following scripts that will build a new image and allows an override of the default health check text via a configuration value.

- `build/deployWithDefaults.sh`
- `build/deployWithOverride.sh`

### A couple things I didn't have time to do

- configure scaling policies for the ASG
- configure s3 and a CloudFront distribution for an image


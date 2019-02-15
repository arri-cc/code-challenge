terraform = {
  required_version = ">= 0.11.11"
  backend          "s3"             {}
}

provider "aws" {
  region = "us-west-2"
}

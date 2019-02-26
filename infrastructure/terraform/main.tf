terraform = {
  required_version = ">= 0.11.11"
  backend          "s3"             {}
}

provider "aws" {
  version = "~> 1.60.0"
  region  = "us-west-2"
}

provider "aws" {
  version = "~> 1.60.0"

  # instance to access us-east-1
  region = "us-east-1"
  alias  = "useast1"
}

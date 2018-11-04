variable "aws_region" {
  description = "The region where this project will be deployed"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile from ~/.aws/config to use"
}

variable "aws_role_arn" {
  description = "AWS IAM role ARN to assume for provider operations"
}

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  version = "1.33.0"

  assume_role {
    role_arn = "${var.aws_role_arn}"
  }
}

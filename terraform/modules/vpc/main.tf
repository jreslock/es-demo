data "aws_caller_identity" "current" {}

resource "aws_vpc" "es-demo" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags {
    Name      = "ES Demo"
    terraform = true
  }
}

# The VPC should have a place for logs (ALB/NLB)
# The account ID hard-coded here is the AWS ELB account for us-east-1 which needs to be able to put objects in our bucket
resource "aws_s3_bucket" "logs" {
  bucket        = "logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  acl           = "private"

  server_side_encryption_configuration {
    "rule" {
      "apply_server_side_encryption_by_default" {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name      = "Logs Bucket"
    terraform = true
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::127311923021:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::logs-${data.aws_caller_identity.current.account_id}/*"
    }
  ]
}
POLICY
}

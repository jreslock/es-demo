resource "aws_iam_role" "es-demo" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy" "es-demo" {
  name = "es-demo"
  role = "${aws_iam_role.es-demo.id}"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_instance_profile" "es-demo" {
  name = "es-demo"
  role = "${aws_iam_role.es-demo.id}"
}

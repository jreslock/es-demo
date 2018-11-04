variable "ssh_public_key" {}

data "aws_ami" "ssh" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  owners = ["137112412989"]
}

resource "aws_key_pair" "ssh" {
  key_name   = "ssh"
  public_key = "${var.ssh_public_key}"
}

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.ssh.id}"
  instance_type          = "t3.micro"
  key_name               = "${aws_key_pair.ssh.key_name}"
  subnet_id              = "${module.vpc.public_a_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}"]

  tags {
    Name      = "Bastion"
    terraform = true
  }
}

resource "aws_security_group" "ssh" {
  name   = "ssh"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "SSH"
    terraform = true
  }
}

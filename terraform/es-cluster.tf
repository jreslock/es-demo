variable "es_ami" {
  description = "The AMI to use for ES Instances"
}

variable "tls_cert_arn" {
  description = "The ARN of an TLS cert managed by ACM"
}

locals {
  private_subnets = "${module.vpc.private_a_subnet_id},${module.vpc.private_b_subnet_id},${module.vpc.private_c_subnet_id}"
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

resource "aws_security_group" "lb" {
  name   = "load balancer"
  vpc_id = "${module.vpc.vpc_id}"

  # Allow 443/HTTPS ingress from everywhere
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 9200
    protocol    = "tcp"
    to_port     = 9200
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "asg" {
  name   = "cluster"
  vpc_id = "${module.vpc.vpc_id}"

  # Allow ingress from the ALB on port 9200
  ingress {
    from_port       = 9200
    protocol        = "tcp"
    to_port         = 9200
    security_groups = ["${aws_security_group.lb.id}"]
  }

  # Allow ingress from the bastion host for ssh
  ingress {
    from_port       = 22
    protocol        = "tcp"
    to_port         = 22
    security_groups = ["${aws_security_group.ssh.id}"]
  }

  # Allow full egress
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "es-cluster" {
  image_id             = "${var.es_ami}"
  instance_type        = "m4.large"
  iam_instance_profile = "${module.iam.es_demo_instance_profile}"
  key_name             = "${aws_key_pair.ssh.key_name}"
  security_groups      = ["${aws_security_group.asg.id}"]
}

resource "aws_autoscaling_group" "es-cluster" {
  name             = "es-demo"
  desired_capacity = 3
  max_size         = 6
  min_size         = 3

  launch_configuration = "${aws_launch_configuration.es-cluster.id}"
  vpc_zone_identifier  = ["${module.vpc.private_a_subnet_id}","${module.vpc.private_b_subnet_id}","${module.vpc.private_c_subnet_id}"]

  tags = [
    {
      key                 = "terraform"
      value               = true
      propagate_at_launch = true
    },
  ]
}

resource "aws_lb_target_group" "es-target-group" {
  name     = "es-target-group"
  port     = 9200
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  health_check {
    interval            = "30"
    path                = "/"
    port                = "9200"
    protocol            = "HTTP"
    timeout             = "3"
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    matcher             = "200"
  }
}

resource "aws_autoscaling_attachment" "es" {
  autoscaling_group_name = "${aws_autoscaling_group.es-cluster.id}"
  alb_target_group_arn   = "${aws_lb_target_group.es-target-group.arn}"
}

resource "aws_lb" "es" {
  name               = "es-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb.id}"]
  subnets            = ["${module.vpc.public_a_subnet_id}","${module.vpc.public_b_subnet_id}","${module.vpc.public_c_subnet_id}"]

  access_logs {
    bucket  = "${module.vpc.logs_bucket}"
    prefix  = "es-lb"
    enabled = true
  }

  tags {
    Name      = "es-lb"
    terraform = true
  }
}

resource "aws_lb_listener" "es-https" {
  "default_action" {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.es-target-group.arn}"
  }

  load_balancer_arn = "${aws_lb.es.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "${local.ssl_policy}"
  certificate_arn   = "${var.tls_cert_arn}"
}

resource "aws_lb_listener" "es-http" {
  "default_action" {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.es-target-group.arn}"
  }

  load_balancer_arn = "${aws_lb.es.arn}"
  port              = 80
  protocol          = "HTTP"
}

resource "aws_lb_listener_rule" "redirect-http-to-https" {
  "action" {
    target_group_arn = "${aws_lb_target_group.es-target-group.arn}"
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  "condition" {
    field  = "host-header"
    values = ["*.jreslock-aws.net"]
  }

  listener_arn = "${aws_lb_listener.es-http.arn}"
}

resource "aws_route53_record" "es" {
  name    = "es-demo.${var.domain}"
  type    = "A"
  zone_id = "${module.dns.public_zone_id}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_lb.es.dns_name}"
    zone_id                = "${aws_lb.es.zone_id}"
  }
}

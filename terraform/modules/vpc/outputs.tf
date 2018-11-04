output "vpc_id" {
  value = "${aws_vpc.es-demo.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.es-demo.cidr_block}"
}

output "default_sg_id" {
  value = "${aws_vpc.es-demo.default_security_group_id}"
}

output "default_rtb_id" {
  value = "${aws_vpc.es-demo.default_route_table_id}"
}

output "private_a_subnet_id" {
  value = "${aws_subnet.private-a.id}"
}

output "private_b_subnet_id" {
  value = "${aws_subnet.private-b.id}"
}

output "private_c_subnet_id" {
  value = "${aws_subnet.private-c.id}"
}

output "public_a_subnet_id" {
  value = "${aws_subnet.public-a.id}"
}

output "public_b_subnet_id" {
  value = "${aws_subnet.public-b.id}"
}

output "public_c_subnet_id" {
  value = "${aws_subnet.public-c.id}"
}

output "logs_bucket" {
  value = "${aws_s3_bucket.logs.bucket}"
}

resource "aws_vpc_dhcp_options" "private-dhcp-options" {
  domain_name = "${var.private_zone_name}"

  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name      = "Private DHCP Options"
    terraform = true
  }
}

resource "aws_vpc_dhcp_options_association" "private-dhcp-options" {
  dhcp_options_id = "${aws_vpc_dhcp_options.private-dhcp-options.id}"
  vpc_id          = "${aws_vpc.es-demo.id}"
}

# Private subnets for 1a,1b,1c
resource "aws_subnet" "private-a" {
  availability_zone       = "us-east-1a"
  cidr_block              = "${var.private_1a_cidr}"
  map_public_ip_on_launch = false
  vpc_id                  = "${aws_vpc.es-demo.id}"

  tags {
    Name      = "Private-1a"
    terraform = true
  }
}

resource "aws_subnet" "private-b" {
  availability_zone       = "us-east-1b"
  cidr_block              = "${var.private_1b_cidr}"
  map_public_ip_on_launch = false
  vpc_id                  = "${aws_vpc.es-demo.id}"

  tags {
    Name      = "Private-1b"
    terraform = true
  }
}

resource "aws_subnet" "private-c" {
  availability_zone       = "us-east-1c"
  cidr_block              = "${var.private_1c_cidr}"
  map_public_ip_on_launch = false
  vpc_id                  = "${aws_vpc.es-demo.id}"

  tags {
    Name      = "Private-1c"
    terraform = true
  }
}

# EIP's for the Nat Gateways in each subnet
resource "aws_eip" "nat-a" {
  vpc = true
}

resource "aws_eip" "nat-b" {
  vpc = true
}

resource "aws_eip" "nat-c" {
  vpc = true
}

# 1 NAT GW per subnet/AZ
resource "aws_nat_gateway" "a" {
  allocation_id = "${aws_eip.nat-a.id}"
  subnet_id     = "${aws_subnet.private-a.id}"
}

resource "aws_nat_gateway" "b" {
  allocation_id = "${aws_eip.nat-b.id}"
  subnet_id     = "${aws_subnet.private-b.id}"
}

resource "aws_nat_gateway" "c" {
  allocation_id = "${aws_eip.nat-c.id}"
  subnet_id     = "${aws_subnet.private-c.id}"
}

# Route table and routes for each subnet
resource "aws_route_table" "a" {
  vpc_id = "${aws_vpc.es-demo.id}"

  tags {
    terraform = true
  }
}

resource "aws_route_table" "b" {
  vpc_id = "${aws_vpc.es-demo.id}"

  tags {
    terraform = true
  }
}

resource "aws_route_table" "c" {
  vpc_id = "${aws_vpc.es-demo.id}"

  tags {
    terraform = true
  }
}

resource "aws_route" "a" {
  route_table_id         = "${aws_route_table.a.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.a.id}"
}

resource "aws_route" "b" {
  route_table_id         = "${aws_route_table.b.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.b.id}"
}

resource "aws_route" "c" {
  route_table_id         = "${aws_route_table.c.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.c.id}"
}

resource "aws_route_table_association" "a" {
  route_table_id = "${aws_route_table.a.id}"
  subnet_id      = "${aws_subnet.private-a.id}"
}

resource "aws_route_table_association" "b" {
  route_table_id = "${aws_route_table.b.id}"
  subnet_id      = "${aws_subnet.private-b.id}"
}

resource "aws_route_table_association" "c" {
  route_table_id = "${aws_route_table.c.id}"
  subnet_id      = "${aws_subnet.private-c.id}"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.es-demo.id}"

  tags {
    Name      = "public-gateway"
    terraform = true
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.es-demo.id}"

  tags {
    Name      = "public-routes"
    terraform = true
  }
}

resource "aws_route" "public-igw" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_subnet" "public-a" {
  vpc_id                  = "${aws_vpc.es-demo.id}"
  cidr_block              = "${var.public_1a_cidr}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.main"]

  tags {
    Name      = "public-a"
    terraform = true
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                  = "${aws_vpc.es-demo.id}"
  cidr_block              = "${var.public_1b_cidr}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.main"]

  tags {
    Name      = "public-b"
    terraform = true
  }
}

resource "aws_subnet" "public-c" {
  vpc_id                  = "${aws_vpc.es-demo.id}"
  cidr_block              = "${var.public_1c_cidr}"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.main"]

  tags {
    Name      = "public-c"
    terraform = true
  }
}

resource "aws_route_table_association" "public-a" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public-a.id}"
}

resource "aws_route_table_association" "public-b" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public-b.id}"
}

resource "aws_route_table_association" "public-c" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${aws_subnet.public-c.id}"
}

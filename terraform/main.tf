provider "aws" {}

resource "aws_vpc" "esig_vpc" {
  cidr_block = "172.31.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = false
  tags = {
    Name = "ESIG"
  }
}

resource "aws_subnet" "esig_public_subnet" {
  vpc_id                  = "${aws_vpc.esig_vpc.id}"
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
  	Name =  "ESIG public subnet"
  }
}

resource "aws_subnet" "esig_private_subnet" {
  vpc_id = "${aws_vpc.esig_vpc.id}"
  cidr_block = "172.31.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
  	Name =  "ESIG private subnet"
  }
}

resource "aws_internet_gateway" "esig_gateway" {
  vpc_id = "${aws_vpc.esig_vpc.id}"
  tags {
    Name = "ESIG Internet Gateway"
  }
}

resource "aws_route" "esig_internet_access" {
  route_table_id = "${aws_vpc.esig_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.esig_gateway.id}"
}

resource "aws_eip" "esig_eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.esig_gateway"]
}

resource "aws_nat_gateway" "esig_nat" {
  allocation_id = "${aws_eip.esig_eip.id}"
  subnet_id = "${aws_subnet.esig_public_subnet.id}"
  depends_on = ["aws_internet_gateway.esig_gateway"]
}

resource "aws_route_table" "esig_private_route_table" {
  vpc_id = "${aws_vpc.esig_vpc.id}"

  tags {
    Name = "ESIG private route table"
  }
}

resource "aws_route" "esig_private_route" {
	route_table_id  = "${aws_route_table.esig_private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.esig_nat.id}"
}

resource "aws_route_table_association" "esig_public_subnet_association" {
  subnet_id = "${aws_subnet.esig_public_subnet.id}"
  route_table_id = "${aws_vpc.esig_vpc.main_route_table_id}"
}

resource "aws_route_table_association" "esig_private_subnet_association" {
  subnet_id = "${aws_subnet.esig_private_subnet.id}"
  route_table_id = "${aws_route_table.esig_private_route_table.id}"
}

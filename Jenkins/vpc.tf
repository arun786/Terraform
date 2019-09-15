//step 1 create vpc
resource "aws_vpc" "dev-vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc for jenkins/fargate"
  }
}

//step 2 internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
}
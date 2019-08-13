variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "region" {}
variable "key_name" {
  default = "terraformkey"
}

//For VPC
variable "network_address_space" {
  default = "10.1.0.0/16"
}

//Two subnets
variable "subnet1_address_space" {
  default = "10.1.0.0/24"
}

variable "subnet2_address_space" {
  default = "10.1.1.0/24"
}

data "aws_availability_zones" "available" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

//for vpc
resource "aws_vpc" "vpc" {
  cidr_block = "${var.network_address_space}"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

//Subnet details
resource "aws_subnet" "subnet1" {
  cidr_block = "${var.subnet1_address_space}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  cidr_block = "${var.subnet2_address_space}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}}"
  }
}

resource "aws_route_table_association" "rta_subnet1" {
  route_table_id = "${aws_route_table.rtb.id}"
  subnet_id = "${aws_subnet.subnet1.id}"
}

resource "aws_route_table_association" "rta_subnet2" {
  route_table_id = "${aws_route_table.rtb.id}"
  subnet_id = "${aws_subnet.subnet2.id}"
}

resource "aws_security_group" "sg" {
  name = "ngnx_sg"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami = "ami-035b3c7efe6d061d5"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet1.id}"
  key_name = "${var.key_name}"

  connection {
    user = "ec2-user"
    host = self.public_ip
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"

    ]
  }
}



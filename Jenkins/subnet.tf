//step 3 subnet
resource "aws_subnet" "jenkins_subnet" {
  cidr_block = "${var.subnet_cidr_block}"
  vpc_id = "${aws_vpc.dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available_zone.names[0]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins_subnet"
  }
}
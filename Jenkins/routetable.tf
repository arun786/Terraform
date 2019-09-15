//step 4 route table
resource "aws_route_table" "jenkins_rt" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  route {
    cidr_block = "${var.cidr_block}"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Jenkins_public_rt"
  }
}

//step 5 route table association
resource "aws_route_table_association" "rt_ass" {
  route_table_id = "${aws_route_table.jenkins_rt.id}"
  subnet_id = "${aws_subnet.jenkins_subnet.id}"
}
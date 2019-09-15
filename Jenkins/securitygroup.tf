# Create Security Group specific to Jenkins, allowing inbound for port
# 80(default, if jenkins configured to run on 80),22(SSH) and 8080(Jenkins if configured to run on 8080)
# outbound is allowed to all
resource "aws_security_group" "sg" {
  name = "jenkins_sg"
  vpc_id = "${aws_vpc.dev-vpc.id}"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [
      "${var.cidr_block}"
    ]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "${var.cidr_block}"
    ]
  }

  #for Jenkins
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = [
      "${var.cidr_block}"
    ]
  }

  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = [
      "${var.cidr_block}"
    ]
  }
}
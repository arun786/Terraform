output "vpc_id" {
  value = "${aws_vpc.dev-vpc.id}"
}

output "subnet_id" {
  value = "${aws_subnet.jenkins_subnet.id}"
}

output "ec2-ip" {
  value = "${aws_instance.ec2.associate_public_ip_address}"
}
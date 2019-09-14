provider "aws" {
  region = "${var.region}"
}

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

# Create a new ec2 Instance
resource "aws_instance" "ec2" {
  ami = "${var.linux_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.jenkins_subnet.id}"
  key_name = "${var.key_name}"
  security_groups = [
    "${aws_security_group.sg.id}"]


  connection {
    type = "ssh"
    user = "${var.user}"
    private_key = "${file(var.private_key_path)}"
    host = self.public_ip
    timeout = "2"
    agent = false
  }

  tags = {
    Name = "docker_jenkins"
  }

  provisioner "file" {
    source = "Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "file" {
    source = "jenkins_setup.sh"
    destination = "/tmp/jenkins_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # to convert the sh file in unix format, we require dos2unix
      "sudo yum install dos2unix -y",
      "chmod +x /tmp/jenkins_setup.sh",
      "dos2unix /tmp/jenkins_setup.sh",
      "/tmp/jenkins_setup.sh ${aws_instance.ec2.public_ip} ${var.port}",
      "JENKINS_HOST=${aws_instance.ec2.public_ip}",
      "pass=$(sudo cat /var/jenkins_home/secrets/initialAdminPassword)",
      "echo $pass",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[0]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[1]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[2]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[3]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[4]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[5]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[6]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass install-plugin ${var.plugins[7]} -deploy",
      "sudo java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://$JENKINS_HOST:${var.port} -auth admin:$pass restart",
      "echo use the aws_instance_public_dns to go to jenkins screen"
    ]
  }
}
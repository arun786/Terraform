provider "aws" {
  region = "${var.region}"
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
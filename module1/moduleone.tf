variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "region" {}
variable "key_name" {
  default = "terraformkey"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "nginx" {
  ami = "ami-035b3c7efe6d061d5"
  instance_type = "t2.micro"
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

output "aws_instance_public" {
  value = "${aws_instance.nginx.public_dns}"
}


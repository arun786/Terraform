variable "region" {
  default = "us-west-2"
  description = "Oregon"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  description = "cidr block for vpc"
}
variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
  description = "subnet cidr block"
}

variable "cidr_block" {
  default = "0.0.0.0/0"
}

variable "port" {}

variable "plugins" {
}

variable "linux_ami" {
  default = "ami-08d489468314a58df"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "user" {
  default = "ec2-user"
}

variable "private_key_path" {}

variable "key_name" {}


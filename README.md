# Requirement

    step 1 : To install Jenkins on Docker in ec2 instance, configure plugins with terraform script 
    step 2 : Configure Jenkins, add user and git credentials and ecr credentials.
    step 3 : Checkout api from github using Jenkins
    step 4 : create a docker image
    step 5 : push the docker image to ecr
    step 6 : run the docker iamge on aws ecr fargate.

# Terraform basics

    Softwares to install
    
1. [Terraform](https://www.terraform.io/downloads.html) or Install Plugin Terraform in Intellij
2. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html)

    Basic Commands used in Terraform 
    
    1. terraform init -backend-config="terraform.tf"
    2. terraform plan -var-file="terraform.tfvars"
    3. terraform apply -var-file="terraform.tfvars"
    4. terraform destroy -var-file="terraform.tfvars"


# How to create link between aws and your laptop

    1. Create a key pair and download it to a specific path, the .pem file path will be the private_key_path
    2. key_name will be name of the key pair without any extension
    3. Create a user, give the required permission to create infrastructure and download the access key and secret key
    which will be used to confgure aws. 
    
    Basically once the aws cli is installed, you can use it to configure by using the below command
    
    on terminal use 
    aws configure - it will ask for entering the below, which is to be entered from the downloaded file  
    
    AWS Access Key ID [****************I36M]:
    AWS Secret Access Key [****************wVbw]:
    Default region name [us-west-2]:
    Default output format [None]:


# Step 1 :  Install Jenkins on ec2 using Terraform script

    To set up Jenkins in aws ec2, the below terraform script is used, which 
    creates Infrastructure step by step, install docker , jenkins and its plugin.
    
    We need to then manually configure the admin name and password
    
    1. vpc
    2. internet gateway
    3. subnet
    4. route table
    5. security group
    6. ec2 instance
    7. script for installing 
    
    
# code as Infrastructure

   There are various tf files used for various purpose.
    
   1. vpc.tf
    
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
        
   2. subnet.tf
   
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
           
   3. routetable.tf
   
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
            
   4. securitygroup.tf
   
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
            
   5. data.tf (used to get important info from aws, in this case it will be az)
   
            data "aws_availability_zones" "available_zone" {
            }
            
   6. terraform.tf (details of the s3 bucket, which will store all the info of the infrastructure created)
   
            terraform {
              backend "s3" {
                key = "dev/vpc"
                bucket = "ecs-fargate-docker"
                region = "us-west-2"
              }
            }
            
   7. output.tf (Any info which is to be stored in s3 bucket can be used to as an output)
   
            output "vpc_id" {
              value = "${aws_vpc.dev-vpc.id}"
            }
            
            output "subnet_id" {
              value = "${aws_subnet.jenkins_subnet.id}"
            }
            
            output "ec2-ip" {
              value = "${aws_instance.ec2.associate_public_ip_address}"
            }
            
   8. terraform.tfvars (List of variables and its value to be used)
   
            region = "us-west-2"
            cidr_block = "0.0.0.0/0"
            port = "80"
            plugins = [
              "amazon-ecr",
              "workflow-aggregator",
              "gradle",
              "github-branch-source",
              "ldap",
              "matrix-auth",
              "jdk-tool",
              "ssh-slaves"]
            private_key_path = "C:\\Users\\Adwiti\\Desktop\\awskey\\keyForVPC.pem"
            key_name = "keyForVPC"
            
            
   9. variable.tf ( this file declares the variable and its default value)
            
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
       
   10. Jenkins_setup.sh (installs java, docker, docker client, jenkins, jenkins plugin and displays the initial password)
   
            #!/bin/bash
            
            sudo yum remove java-1.7.0-openjdk -y
            sudo yum install java-1.8.0 -y
            sudo yum install docker -y
            sudo mkdir -p /var/jenkins_home
            sudo chown -R 1000:1000 /var/jenkins_home
            sudo mkdir jenkins-docker
            sudo cp /tmp/Dockerfile jenkins-docker
            sudo service docker start
            sudo usermod -aG docker ec2-user
            sudo usermod -a -G docker jenkins
            cd jenkins-docker
            sudo docker build -t jenkins-docker .
            cat $2
            sudo docker run -p $2:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --name jenkins --group-add 497 -d jenkins-docker:latest
            sleep 20
            echo "initial jenkins password is as below"
            sudo cat /var/jenkins_home/secrets/initialAdminPassword
            JENKINS_HOST=$1
            sudo cat ${JENKINS_HOST}
            sleep 20
            
            
   11. Dockerfile ( This file is used to create docker client which can be used to run docker commands in Jenkins)
    
            FROM jenkins/jenkins:latest
            USER root
            
            RUN mkdir -p /tmp/download && curl -L https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz | tar -xz -C /tmp/download && rm -rf /tmp/download/docker/dockerd && mv /tmp/download/docker/docker* /usr/local/bin/ && rm -rf /tmp/download && groupadd -g 497 docker && usermod -aG staff,docker jenkins
            
            user jenkins
            
            
# Once the script is run, we need to configure Jenkins manually

![Initial Jenkins Screen](https://github.com/arun786/Terraform/blob/master/images/1.JPG)

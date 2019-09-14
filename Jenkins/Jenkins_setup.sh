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



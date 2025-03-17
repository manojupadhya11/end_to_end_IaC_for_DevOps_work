#!/bin/bash

echo "docker installation begins"

yum install docker -y
systemctl enable docker
systemctl start docker
docker --version

echo "Docker is installed succesfully"

echo "Creation of Jenkinks single node Server using docker"
docker run -p 8080:8080 -p 50000:50000 -dit --name jenkins --restart=on-failure -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk17
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "Jenkins installed succesfully"


echo "Kubernetes installation"
#Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
rpm -Uvh minikube-latest.x86_64.rpm
minikube start --force

#Install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.3/2023-11-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
cp ./kubectl /usr/bin/

echo "minikube cluster and kubectl agent installed"
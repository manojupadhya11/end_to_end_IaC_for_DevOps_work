resource "aws_vpc" "DevOps_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "DevOps_VPC"
  }
}

resource "aws_subnet" "DevOps_subnet1" {
    vpc_id = aws_vpc.DevOps_vpc.id
    cidr_block = var.subnet1_cidr
    availability_zone = var.availbility_zone_1a
    tags = {
      Name = "DevOps_Subnet1"
    }
}

resource "aws_subnet" "DevOps_subnet2" {
    vpc_id = aws_vpc.DevOps_vpc.id
    cidr_block = var.subnet2_cidr
    availability_zone = var.availbility_zone_1b
    tags = {
      Name = "DevOps_Subnet2"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.DevOps_vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.DevOps_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "rt"
    }
}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.DevOps_subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.DevOps_subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "DevOps_SG" {
    name        = "DevOps Security group"
    description = "Allow traffic only related to DevOps ports"
    vpc_id      = aws_vpc.DevOps_vpc.id

    ingress {
        description      = "HTTP from VPC"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        #ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
        description      = "SSH from VPC"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "DevOps SG"
    }
}
resource "aws_instance" "ec2_instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.DevOps_subnet1.id
  vpc_security_group_ids = [aws_security_group.DevOps_SG.id]
  key_name = var.key_name
  #user_data = base64encode(file("${path.module}/userdata.sh"))
  associate_public_ip_address = true
  #user_data = file("userdata-script.sh")

  #Kubernetes userdata
  user_data = <<-EOF
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
    EOF
  tags = {
    Name = "DevOps_EC2_Instance"
  }

}
  


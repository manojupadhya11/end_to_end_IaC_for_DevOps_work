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
    tags = {
      Name = "DevOps_EC2_Instance"
    }

      # Define the file to be copied
    provisioner "file" {
        source      = "userdata.sh"
        destination = "/home/ec2-user/userdata.sh"  # Destination path on the EC2 instance
    }

  # SSH connection block
  connection {
    type        = "ssh"
    user        = "ec2-user"  # Modify for your EC2 instance user
    private_key = var.key_name
    host        = self.public_ip
  }

  # Optionally, run a command after the file is copied
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/userdata.sh",  # Example to change permissions
      "sh userdata.sh"
    ]
  }
}
  


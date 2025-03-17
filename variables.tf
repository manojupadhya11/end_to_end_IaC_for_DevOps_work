variable "cidr_block" {
    description = "CIDR block for the DevOps VPC"
    type = string
    default = "11.0.0.0/16"
}

variable "subnet1_cidr" {
    description = "CIDR block for the DevOps Subnet1"
    type = string
    default = "11.0.1.0/24"
}

variable "subnet2_cidr" {
    description = "CIDR block for the DevOps Subnet2"
    type = string
    default = "11.0.2.0/24"
}

variable "availbility_zone_1a" {
    description = "Availability Zone for the DevOps Subnet1"
    type = string
    default = "ap-south-1a"
}

variable "availbility_zone_1b" {
    description = "Availability Zone for the DevOps Subnet2"
    type = string
    default = "ap-south-1b"
}

variable "instance_type" {
    description = "Instance type for the EC2 instance"
    type = string
    default = "t2.medium"
}

variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    type = string
    default = "ami-05c179eced2eb9b5b"
}

variable "key_name" {
    description = "Key name for the EC2 instance"
    type = string
    default = "Ansible2"
}
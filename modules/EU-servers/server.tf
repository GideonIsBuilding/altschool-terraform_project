provider "aws" {
  region = var.app_region
}

#-----------------------------------------------
# Create VPC
#-----------------------------------------------
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.app_region}-vpc"
  }
}

#-----------------------------------------------
# Create Subnet and Specify the Availability Zone
#-----------------------------------------------
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.app_region} Public Subnet ${count.index + 1}"
  }
}
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.app_region} Private Subnet ${count.index + 1}"
  }
}

#-----------------------------------------------
# Set Up Internet Gateway
#-----------------------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "${var.app_region}-gw"
  }
}

#-----------------------------------------------
# Create Route Table for the Public Subnets
#-----------------------------------------------
resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.app_region} Route Table"
  }
}

#-----------------------------------------------
# Associate Public Subnets with Route Table
#-----------------------------------------------
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.main-route-table.id
}

#-----------------------------------------------
# Allow designated ports using security groups
#-----------------------------------------------
resource "aws_security_group" "allow-web" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow web"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow Web"
  }
}

#-----------------------------------------------
# Configuring AWS EC2 instance
#-----------------------------------------------
resource "aws_instance" "ubuntu_server" {
  count                       = var.instance_count
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  availability_zone           = var.azs[0]
  key_name                    = "../AltSchool"
  associate_public_ip_address = true
}

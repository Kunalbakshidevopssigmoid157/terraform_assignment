terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


# Creating VPC,name, CIDR and Tags
resource "aws_vpc" "kunal" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"

  tags = {
    Name = "kunal"
  }

}


# Creating Public Subnets in VPC
resource "aws_subnet" "kunal-public" {
  vpc_id                  = aws_vpc.kunal.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "kunal-public"
  }
}

# Creating Private Subnets in VPC
resource "aws_subnet" "kunal-private" {
  vpc_id                  = aws_vpc.kunal.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "kunal-private"
  }
}

# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "kunal-igw" {
  vpc_id = aws_vpc.kunal.id

  tags = {
    Name = "kunal"
  }
}

# Creating Route Tables for Internet gateway
resource "aws_route_table" "kunal-public" {
  vpc_id = aws_vpc.kunal.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kunal-igw.id
  }
  
  
  tags = {
    Name = "kunal-public"
  }
}

# Creating Route Associations public subnets
resource "aws_route_table_association" "kunal-public-a" {
  subnet_id      = aws_subnet.kunal-public.id
  route_table_id = aws_route_table.kunal-public.id
}

# Creating Nat Gateway
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.kunal-public.id
  depends_on    = [aws_internet_gateway.kunal-igw]
}

# Add routes for VPC
resource "aws_route_table" "kunal-private" {
  vpc_id = aws_vpc.kunal.id
  route{
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat-gw.id
    }
  
  

  tags = {
    Name = "kunal-private"
  }
}

# Creating route associations for private Subnets
resource "aws_route_table_association" "kunal-private-a" {
  subnet_id      = aws_subnet.kunal-private.id
  route_table_id = aws_route_table.kunal-private.id
}

# Key pair in making
resource "aws_key_pair" "ssh-private-key" {
  key_name   = "ssh-private-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Storing private key in localfile
resource "local_file" "ssh-private-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "ssh-private-key.pem"
}
# Creation of Security group
resource "aws_security_group" "public-security-group" {
  name        = "public-security-group"
  description = "security group"
  vpc_id      = "${aws_vpc.kunal.id}"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = "security-group"
  }
}


output "aws_security_gr_id" {
  value = "{$aws_security_group.security-group.id}"
}
# EC2 Instance Public Subnets
resource "aws_instance" "public_instance-1" {
  ami           = "ami-02eb7a4783e7e9317"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.public-security-group.id}" ]
  subnet_id = "${aws_subnet.kunal-public.id}"
  key_name = "ssh-private-key"
  associate_public_ip_address = true
  tags = {
    Name = "kunal-public-1"
  }
  user_data = file("userdata.tpl")
}

#EC2 Instances Private Subnets

resource "aws_instance" "private_instance-1" {
  ami           = "ami-02eb7a4783e7e9317"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "${aws_security_group.public-security-group.id}" ]
  subnet_id = "${aws_subnet.kunal-private.id}"
  key_name = "ssh-private-key"
  associate_public_ip_address = false
  tags = {
    Name = "kunal-private-1"
  }
    user_data = file("userdata.tpl")
  
}

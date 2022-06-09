provider "aws" {
  region = "us-east-1"
  access_key = "xxxxxx"
  secret_key = "yyyyyy"
}

# VPC
resource "aws_vpc" "vpc-production" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "vpc_production_terraform-website"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw-production" {
  vpc_id = aws_vpc.vpc-production.id

  tags = {
    "Name" = "gw_production_terraform-website"
  }  
}

# Route Table (saída para internet)
resource "aws_route_table" "rt-production" {
  vpc_id = aws_vpc.vpc-production.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-production.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw-production.id
  }

  tags = {
    "Name" = "rt_production_terraform-website"
  }  
}

# Subnet
resource "aws_subnet" "sn-production" {
  vpc_id = aws_vpc.vpc-production.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "sn_production_terraform-website"
  }  
}

# Associar Route a Subnet 
resource "aws_route_table_association" "rt-sn-production" {
  subnet_id = aws_subnet.sn-production.id
  route_table_id = aws_route_table.rt-production.id
}

# Security Group (liberação de http, https e ssh)
resource "aws_security_group" "sg-production" {
  name = "public-web-ssh"
  description = "Permite acesso ao web server"
  vpc_id = aws_vpc.vpc-production.id

  ingress {
    description = "Permite acesso publico HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Permite acesso publico HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Permite acesso publico SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permite saida a internet"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "sg-production_terraform-website"
  }
}

# Criar uma interface de rede com IP privado fixo na Subnet
resource "aws_network_interface" "eni-production" {
  subnet_id = aws_subnet.sn-production.id
  private_ips = ["10.0.1.42"]
  security_groups = [ aws_security_group.sg-production.id ]

  tags = {
    "Name" = "eni_production_terraform-website"
  }
}

# Elastic IP (IP externo fixo)
resource "aws_eip" "eip-production" {
  vpc = true
  network_interface = aws_network_interface.eni-production.id
  associate_with_private_ip = "10.0.1.42"
  depends_on = [ aws_internet_gateway.gw-production ]

  tags = {
    "Name" = "eip_production_terraform-website"
  }
}

# EC2
resource "aws_instance" "ec2-production" {
  ami = "ami-0022f774911c1d690" // Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "kp_terraform-website"
  
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.eni-production.id
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo usermod -a -G apache ec2-user
    sudo chown -R ec2-user:apache /var/www
    sudo chmod 2775 /var/www
    find /var/www -type d -exec sudo chmod 2775 {} \;
    find /var/www -type f -exec sudo chmod 0664 {} \;
    sudo yum install -y git
    git clone https://github.com/ermogenes/cursos.git /var/www/html
  EOF

  tags = {
    "Name" = "ec2_production_terraform-website"
  }
}

output "ec2-production-public_ip" {
  value = aws_eip.eip-production.public_ip
}

output "ec2-production-public_dns" {
  value = aws_eip.eip-production.public_dns
}

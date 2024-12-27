# VPC Creation
resource "aws_vpc" "tf" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = "true"
  tags = {
    Name = var.vpc_name
  }
}

# Public Subnets Creation
resource "aws_subnet" "pub_sn" {
  count                   = var.pub_subnet_count
  vpc_id                  = aws_vpc.tf.id
  cidr_block              = element(var.pub_subnet_cidr_block, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-pub-sn-${count.index + 1}"
  }
}

# Private Subnets Creation
resource "aws_subnet" "pvt_sn" {
  count                   = var.pvt_subnet_count
  vpc_id                  = aws_vpc.tf.id
  cidr_block              = element(var.pvt_subnet_cidr_block, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false # Private subnets should not have public IPs
  tags = {
    Name = "${var.vpc_name}-pvt-sn-${count.index + 1}"
  }
}

# Internet Gateway Creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
  depends_on = [aws_vpc.tf]
}

# Route Tables for Public Subnet
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-pub-rt"
  }
}

# Route Tables for Private Subnet
resource "aws_route_table" "pvt" {
  vpc_id = aws_vpc.tf.id
  tags = {
    Name = "${var.vpc_name}-pvt-rt"
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "pub_sn_ass" {
  count          = var.pub_subnet_count
  subnet_id      = element(aws_subnet.pub_sn.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "pvt_sn_ass" {
  count          = var.pvt_subnet_count
  subnet_id      = element(aws_subnet.pvt_sn.*.id, count.index)
  route_table_id = aws_route_table.pvt.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# NAT Gateway Creation in the Public Subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.pub_sn.*.id, 0) # Place NAT Gateway in the first public subnet
  tags = {
    Name = "${var.vpc_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw] # Ensure the IGW is created first
}

# Update Private Route Table to use NAT Gateway for Internet access
resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.pvt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id

  depends_on = [aws_nat_gateway.nat_gw] # Ensure NAT Gateway is created first
}


#Example: Allow HTTP Only During Business Hours (9 AM - 5 PM)
# Security Group Creation
resource "aws_security_group" "TF_SG" {
  vpc_id      = aws_vpc.tf.id
  name        = "${var.vpc_name}-sg_name"
  description = "Security group created by Terraform"

  # Loop through the allowed ports and create ingress rules dynamically
  dynamic "ingress" {
    for_each = toset(var.allowed_ports) # Convert list of allowed ports to a set
    content {
      description = "Allow inbound traffic on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere, or use specific IPs if needed
    }
  }

  # Allow inbound traffic on port 3506 based on environment and business hours
  ingress {
    description = "Allow inbound traffic only for port 3506 during business hours"
    from_port   = 3506
    to_port     = 3506
    protocol    = "tcp"
    # Check if the current time is after 9 AM (example)
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules - Allow all outbound traffic
  egress {
    description = "Allow outbound traffic to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-sg"
  }
}


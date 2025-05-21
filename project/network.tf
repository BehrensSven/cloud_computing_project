# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"   # Defines the IP address range for the VPC
  enable_dns_support   = true            # Enables DNS resolution inside the VPC
  enable_dns_hostnames = true            # Allows instances to receive DNS hostnames

  tags = {
    Name = "main-vpc"
  }
}

# Create an Internet Gateway for internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id               # Attach the internet gateway to the VPC

  tags = {
    Name = "main-igw"
  }
}

# Create a Route Table and define default route to the Internet
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"             # All outbound traffic
    gateway_id = aws_internet_gateway.main.id  # Goes through the internet gateway
  }

  tags = {
    Name = "main-route-table"
  }
}

# Create a public subnet in availability zone eu-central-1a
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"         # Subnet IP range
  availability_zone       = "eu-central-1a"       # First availability zone
  map_public_ip_on_launch = true                  # Assign public IPs automatically to instances

  tags = {
    Name = "public-subnet-a"
  }
}

# Create a second public subnet in availability zone eu-central-1b
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"         # Subnet IP range
  availability_zone       = "eu-central-1b"       # Second availability zone
  map_public_ip_on_launch = true                  # Assign public IPs automatically to instances

  tags = {
    Name = "public-subnet-b"
  }
}

# Associate subnet A with the route table to enable internet access
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.main.id
}

# Associate subnet B with the route table to enable internet access
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.main.id
}

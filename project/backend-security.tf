# Security Group for the Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP access from public"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow incoming HTTP traffic on port 80 from anywhere (public internet)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Security Group for EC2 instances – only accessible from the ALB
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow traffic from ALB on port 8000"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP traffic from ALB on port 8000"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only from the ALB SG
  }

  # Optional: Uncomment to allow SSH from EC2 Instance Connect IP range (for debugging)
  # ingress {
  #   description = "Optional SSH access for debugging"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["3.120.0.0/16"] # AWS EC2 Connect (Frankfurt)
  # }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# Security Group for RDS – only accessible from EC2 instances
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access only from EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL connections from EC2 instances on port 3306"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Only from EC2 SG
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

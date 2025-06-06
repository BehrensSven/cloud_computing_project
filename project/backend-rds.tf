# Create a DB Subnet Group that includes both public subnets
# This allows RDS to be deployed across multiple Availability Zones for high availability
resource "aws_db_subnet_group" "django" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

# Create the actual RDS MySQL database instance
resource "aws_db_instance" "django" {
  identifier              = "django-db"               # Unique name for the database instance
  engine                  = "mysql"                   # Specify the database engine
  engine_version          = "8.0"                     # Use MySQL version 8.0
  instance_class          = "db.t3.micro"             # Small instance type for development or testing
  allocated_storage       = 20                        # Storage size in GB
  storage_type            = "gp2"                     # General purpose SSD storage

  db_subnet_group_name    = aws_db_subnet_group.django.name # Assign the DB to our defined subnet group
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]  # Restrict access via security group

  db_name                 = var.db_name               # Database name (from variables)
  username                = var.db_username           # DB admin username (from variables)
  password                = var.db_password           # DB admin password (from variables)
  port                    = 3306                      # MySQL default port

  multi_az                = true                      # Activates automatic replication in second AZ, for the two AZs in the two subnets
  publicly_accessible     = false                     # Do not expose DB to the public internet
  skip_final_snapshot     = true                      # Skip snapshot when deleting (for test environments)
  backup_retention_period = 7                         # Backup every 7 days
  backup_window = "03:00-04:00"                       # Backup schedule
  maintenance_window = "sun:04:00-sun:05:00"          # Maintenance schedule

  tags = {
    Name = "django-db"
  }
}

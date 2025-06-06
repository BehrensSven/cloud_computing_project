# Launch Template defines how EC2 instances should be launched
resource "aws_launch_template" "django" {
  name_prefix   = "django-template-"
  image_id      = var.ami_id         # AMI ID for Ubuntu 22.04 (defined in variables)
  instance_type = var.instance_type  # Instance type, e.g., t3.micro
  key_name      = var.key_name       # SSH key to access instances (optional for debugging)

  # Attach the EC2 security group (only allows traffic from ALB on port 8000)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # This script is automatically run when an instance starts (cloud-init)
  user_data = base64encode(<<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive

    # Set database credentials from Terraform variables
    export DB_NAME="${var.db_name}"
    export DB_USER="${var.db_username}"
    export DB_PASSWORD="${var.db_password}"
    export DB_HOST="${aws_db_instance.django.address}"

    # Install necessary packages for Python and MySQL client
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y python3-venv git mysql-client build-essential default-libmysqlclient-dev python3-dev pkg-config

    sudo ufw allow 8000/tcp
    sudo ufw enable
    
    # Clone Django backend from GitHub
    cd /home/ubuntu
    git clone https://github.com/BehrensSven/unternehmenswebseite-backend.git
    cd unternehmenswebseite-backend

    # Create and activate Python virtual environment
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

    # Wait for the RDS MySQL database to become available
    for i in {1..30}; do
      nc -z ${aws_db_instance.django.address} 3306 && break
      echo "Waiting for RDS..."
      sleep 5
    done

    # Re-activate environment and install MySQL driver
    source /etc/environment
    cd /home/ubuntu/unternehmenswebseite-backend
    source venv/bin/activate
    pip install mysqlclient

    # Run Django migrations (create DB tables)
    python3 manage.py migrate || echo "Migration failed"

    # Start Gunicorn server in background with logging
    nohup ./venv/bin/gunicorn unternehmenswebseite.wsgi:application \
      --bind 0.0.0.0:8000 > /home/ubuntu/gunicorn.log 2>&1 &
  EOF
  )

  # Tag all launched instances for easier identification
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "django-backend"
    }
  }

  # Wait for the database to be created before launching EC2
  depends_on = [aws_db_instance.django]
}

# Auto Scaling Group automatically manages EC2 instance count
resource "aws_autoscaling_group" "django" {
  name                      = "django-asg"
  max_size                  = 2     # Maximum number of instances
  min_size                  = 1     # Minimum number of instances
  desired_capacity          = 1     # Start with 1 instance
  vpc_zone_identifier       = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ] # Place instances across 2 public subnets for high availability

  # Link the launch template that defines instance config
  launch_template {
    id      = aws_launch_template.django.id
    version = "$Latest"
  }

  # Register instances with ALB target group
  target_group_arns = [aws_lb_target_group.django.arn]

  # Use EC2 health checks to monitor instance health
  health_check_type         = "EC2"
  health_check_grace_period = 60

  # Tag instances created by this ASG
  tag {
    key                 = "Name"
    value               = "django-backend"
    propagate_at_launch = true
  }

  # Ensure the Target Group and DB exist before creating this group
  depends_on = [
    aws_lb_target_group.django,
    aws_db_instance.django
  ]
}

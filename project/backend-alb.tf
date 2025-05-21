# Application Load Balancer (ALB) to distribute incoming traffic
resource "aws_lb" "app" {
  name               = "django-alb"
  internal           = false                      # External (public) Load Balancer
  load_balancer_type = "application"              # ALB (layer 7)
  security_groups    = [aws_security_group.alb_sg.id]  # Apply ALB security group (allows port 80)
  subnets            = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]                                                # ALB spans both public subnets for high availability

  enable_deletion_protection = false              # Set to true for production to avoid accidental deletion

  tags = {
    Name = "django-alb"
  }
}

# Target Group for routing traffic to EC2 instances running Django
resource "aws_lb_target_group" "django" {
  name     = "django-target-group"
  port     = 8000                                # Port on which Django app is listening
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Health checks to monitor instance health
  health_check {
    path                = "/"                    # Root URL checked for a 200 OK response
    protocol            = "HTTP"
    matcher             = "200"                  # Expected response code
    interval            = 30                     # Check every 30 seconds
    timeout             = 5                      # Timeout after 5 seconds
    healthy_threshold   = 2                      # 2 successful checks = healthy
    unhealthy_threshold = 2                      # 2 failed checks = unhealthy
  }

  tags = {
    Name = "django-target-group"
  }
}

# Listener to forward HTTP traffic from ALB to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80                         # Listen for HTTP traffic on port 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"                 # Forward requests to the target group
    target_group_arn = aws_lb_target_group.django.arn
  }
}

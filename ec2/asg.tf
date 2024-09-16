provider "aws" {
  region = "eu-central-1"  # Change to your desired region
}

# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template-"
  image_id      = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "***********"  # Replace with your key pair name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.frontend_sg.id]
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Frontend" > /var/www/html/index.html
              EOF

  tags = {
    Name = "app-instance"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["public-subnet-1", "public-subnet-2", "public-subnet-3"]  # Replace with your public subnet IDs
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.frontend_tg.arn]

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}

# Security Groups
resource "aws_security_group" "frontend_sg" {
  vpc_id = "main-vpc"  # Replace with your VPC ID
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "frontend-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  vpc_id = "main-vpc"  # Replace with your VPC ID
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }
  tags = {
    Name = "backend-sg"
  }
}

# Load Balancer
resource "aws_lb" "alb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_sg.id]
  subnets            = ["your-public-subnet-1-id", "your-public-subnet-2-id", "your-public-subnet-3-id"]  # Replace with your public subnet IDs
  tags = {
    Name = "app-load-balancer"
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "main-vpc"  # Replace with your VPC ID
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
  tags = {
    Name = "frontend-tg"
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "frontend_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.frontend[count.index].id
  port             = 80
}

# Fetch existing VPC
data "aws_vpc" "existing_vpc" {
  id = aws_vpc.demovpc.id
}

# Fetch existing subnets
data "aws_subnet" "subnet_1" {
  id = aws_subnet.public-subnet-1.id
}

data "aws_subnet" "subnet_2" {
  id = aws_subnet.public-subnet-2.id
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name   = "alb-security-group"
  vpc_id = data.aws_vpc.existing_vpc.id

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
    Name = "ALB Security Group"
  }
}

# Create Target Group
resource "aws_lb_target_group" "my_tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing_vpc.id
}

# Create Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]

  tags = {
    Name = "MyApplicationALB"
  }
}

# Create ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

# Attach Existing EC2 Instances to Target Group
resource "aws_lb_target_group_attachment" "attach_instance1" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = "i-0826710b942a5ef51" #replace with your instance id 
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach_instance2" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = "i-0e7b5995e35493cdb"  #replace with your instance id
  port             = 80
}

# Output ALB DNS Name
output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}

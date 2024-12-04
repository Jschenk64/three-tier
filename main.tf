provider "aws" {
  region = "eu-central-1"
}

# VPC
resource "aws_vpc" "dvs_vpc" {
  cidr_block           = "10.49.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "DVS-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "dvs_igw" {
  vpc_id = aws_vpc.dvs_vpc.id
  tags = {
    Name = "DVS-IGW"
  }
}

# Subnets
resource "aws_subnet" "dvs_pub_sub1" {
  vpc_id            = aws_vpc.dvs_vpc.id
  cidr_block        = "10.49.150.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"
  tags = {
    Name = "DVS-Pub-Sub1"
  }
}

resource "aws_subnet" "dvs_pub_sub2" {
  vpc_id            = aws_vpc.dvs_vpc.id
  cidr_block        = "10.49.151.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1b"
  tags = {
    Name = "DVS-Pub-Sub2"
  }
}

resource "aws_subnet" "dvs_priv_sub1" {
  vpc_id            = aws_vpc.dvs_vpc.id
  cidr_block        = "10.49.152.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "DVS-Priv-Sub1"
  }
}

resource "aws_subnet" "dvs_priv_sub2" {
  vpc_id            = aws_vpc.dvs_vpc.id
  cidr_block        = "10.49.153.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "DVS-Priv-Sub2"
  }
}

# NAT Gateway
resource "aws_eip" "dvs_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "dvs_nat" {
  allocation_id = aws_eip.dvs_eip.id
  subnet_id     = aws_subnet.dvs_pub_sub1.id
  tags = {
    Name = "DVS-Nat"
  }
}

# Route Tables
resource "aws_route_table" "dvs_pub_rt" {
  vpc_id = aws_vpc.dvs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dvs_igw.id
  }

  tags = {
    Name = "DVS-Pub-RT"
  }
}

# Route Tables Association
resource "aws_route_table_association" "dvs_pub_assoc1" {
  subnet_id      = aws_subnet.dvs_pub_sub1.id
  route_table_id = aws_route_table.dvs_pub_rt.id
}

resource "aws_route_table_association" "dvs_pub_assoc2" {
  subnet_id      = aws_subnet.dvs_pub_sub2.id
  route_table_id = aws_route_table.dvs_pub_rt.id
}

resource "aws_route_table" "dvs_priv_rt" {
  vpc_id = aws_vpc.dvs_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dvs_nat.id
  }

  tags = {
    Name = "DVS_Priv_RT"
  }
}

resource "aws_route_table_association" "dvs_priv_assoc1" {
  subnet_id      = aws_subnet.dvs_priv_sub1.id
  route_table_id = aws_route_table.dvs_priv_rt.id
}

resource "aws_route_table_association" "dvs_priv_assoc2" {
  subnet_id      = aws_subnet.dvs_priv_sub2.id
  route_table_id = aws_route_table.dvs_priv_rt.id
}

# Security Groups (example for web tier)
resource "aws_security_group" "dvs_web" {
  name        = "Web-SG"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.dvs_vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DVS-Web-SG"
  }
}


# EC2 Ubuntu Web-Server
resource "aws_instance" "dvs_web_svr1" {
  ami                    = "ami-0084a47cc718c111a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dvs_pub_sub1.id
  key_name               = "eng-de" 
  vpc_security_group_ids = [aws_security_group.dvs_web.id]

  tags = {
    Name = "DVS-Web-Svr-1"
  }

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y nginx
                systemctl start nginx
                systemctl enable nginx
                echo "Welcome to the Ubuntu Web Tier!" > /var/www/html/index.html
                EOF
}

resource "aws_instance" "dvs_web_svr2" {
  ami                    = "ami-0084a47cc718c111a" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dvs_pub_sub2.id
  key_name               = "eng-de" 
  vpc_security_group_ids = [aws_security_group.dvs_web.id]

  tags = {
    Name = "DVS-Web-Svr-2"
  }

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y nginx
                systemctl start nginx
                systemctl enable nginx
                echo "Welcome to the Ubuntu Web Tier!" > /var/www/html/index.html
                EOF
}


# EC2 Ubuntu App-Server
resource "aws_instance" "dvs_app_svr1" {
  ami                    = "ami-0084a47cc718c111a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dvs_priv_sub1.id
  key_name               = "eng-de"
  vpc_security_group_ids = [aws_security_group.dvs_app.id]

  tags = {
    Name = "DVS-App-Svr-1"
  }

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y python3 python3-pip
                echo "This is the Ubuntu Application Tier" > /home/ubuntu/app.log
                EOF
}


resource "aws_instance" "dvs_app_svr2" {
  ami                    = "ami-0084a47cc718c111a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dvs_priv_sub2.id
  key_name               = "eng-de"
  vpc_security_group_ids = [aws_security_group.dvs_app.id]

  tags = {
    Name = "DVS-App-Svr-2"
  }

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y python3 python3-pip
                echo "This is the Ubuntu Application Tier" > /home/ubuntu/app.log
                EOF
}


# Launch Template
resource "aws_launch_template" "dvs_web_lt" {
  name          = "DVS-Web-LT"
  image_id      = "ami-0084a47cc718c111a" 
  instance_type = "t2.micro"
  key_name      = "eng-de"

  vpc_security_group_ids = [aws_security_group.dvs_web.id]

  user_data = base64encode(<<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y nginx
                systemctl start nginx
                systemctl enable nginx
                echo "Welcome to the Ubuntu Web Tier!" > /var/www/html/index.html
                EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.dvs_pub_sub1.id 
  }

  tags = {
    Name = "DVS-Web-Template"
  }
}


# Target Group
resource "aws_lb_target_group" "dvs_web_tg" {
  name        = "DVS-Web-TG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dvs_vpc.id
  target_type = "instance"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}


# Application Load Balancer
resource "aws_lb" "dvs_alb" {
  name               = "DVS-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dvs_web.id]
  subnets            = [aws_subnet.dvs_pub_sub1.id, aws_subnet.dvs_pub_sub2.id]

  tags = {
    Name = "DVS-ALB"
  }
}

resource "aws_lb_listener" "dvs_web_listener" {
  load_balancer_arn = aws_lb.dvs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dvs_web_tg.arn
  }
}


# Auto Scaling Group
resource "aws_autoscaling_group" "dvs_web_asg" {
  launch_template {
    id      = aws_launch_template.dvs_web_lt.id
    version = "$Latest"
  }

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.dvs_pub_sub1.id,
    aws_subnet.dvs_pub_sub2.id
  ]

  target_group_arns = [aws_lb_target_group.dvs_web_tg.arn]

  tag {
      key                 = "web_tg"
      value               = "DVS-Web-ASG"
      propagate_at_launch = true
   }
  
}


resource "aws_autoscaling_policy" "dvs_web_asg_scale_out" {
  name                   = "scale-out"
  autoscaling_group_name = aws_autoscaling_group.dvs_web_asg.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}

resource "aws_autoscaling_policy" "dvs_web_asg_scale_in" {
  name                   = "scale-in"
  autoscaling_group_name = aws_autoscaling_group.dvs_web_asg.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}

# Application Tier Security Group
resource "aws_security_group" "dvs_app" {
  name        = "App-SG"
  description = "Allow traffic from the web tier to the app tier"
  vpc_id      = aws_vpc.dvs_vpc.id

  ingress {
    description = "Allow HTTP from web tier"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.49.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DVS-App-SG"
  }
}

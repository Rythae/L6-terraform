provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "testing-terraform" {
  ami           = "ami-013f17f36f8b1fefb"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloTerraform"
  }
}

resource "aws_instance" "testing-terraform-2" {
  ami           = "ami-013f17f36f8b1fefb"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloTerraform-2"
  }
}


resource "aws_instance" "testing-terraform-3" {
  ami           = "ami-013f17f36f8b1fefb"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloTerraform-3"
  }
}

resource "aws_instance" "web-server-instance" {
  ami           = "ami-013f17f36f8b1fefb"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "terraform-web-server"
  }
}

resource "aws_security_group" "allow_instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

resource "aws_launch_configuration" "web-servers" {
  image_id        = "ami-013f17f36f8b1fefb"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-example" {
  launch_configuration = aws_launch_configuration.web-servers.id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 10

  load_balancers    = [aws_elb.example.name]
  health_check_type = "ELB" 

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}


data "aws_availability_zones" "all" {}


resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = data.aws_availability_zones.all.names

   health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  
  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "clb_dns_name" {
  value       = aws_elb.example.dns_name
  description = "The domain name of the load balancer"
}
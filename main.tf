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
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
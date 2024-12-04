provider "aws" {
  
}

resource "aws_instance" "dev" {
    ami = "ami-0453ec754f44f9a4a"
    instance_type = "t2.micro"
    key_name = "aws-1"
    tags = {
      Name = "dev-ec3"
    }
}
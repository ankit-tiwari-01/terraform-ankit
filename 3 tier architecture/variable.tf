variable "ami" {
    type = string
    default = "ami-0e2c8caa4b6378d8c"
  
}
variable "instance_type" {
    type = string
    default = "t2.medium"
  
}
variable "key_name" {
    type = string
    default = "ec2-key"
  
}
resource "aws_key_pair" "name" {
    key_name = var.key_name
    public_key = file("~/.ssh/id_ed25519.pub")

    tags = {
      name = var.key_name
    }

     
}


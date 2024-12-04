resource "aws_vpc" "dev_main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev_main"
  }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.dev_main.id
    cidr_block = "10.0.1.0/24"

    tags = {
      name = "public"
    
    }
  
}

resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.dev_main.id
  
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.dev_main.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
}

resource "aws_route_table_association" "rt" {
    route_table_id = aws_route_table.rt.id
    subnet_id = aws_subnet.public.id
  
}

resource "aws_security_group" "allow_ssh" {
    name = "ssh_sg"
    vpc_id = aws_vpc.dev_main.id

    tags = {
      name = "ssh-1"
    }
    ingress {
        description = "to allow all traffic"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}


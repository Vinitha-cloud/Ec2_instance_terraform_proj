terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
 
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_traffic" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_my_ip" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = format("%s/32" , chomp(data.http.my_ip.response_body))
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "my_first_ec2" {
  ami           = "ami-0c3389a4fa5bddaad"
  instance_type = "t2.micro"
  key_name = "new-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
}


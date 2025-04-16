provider "aws" {
    region = "ap-south-1"
}
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}
resource "aws_key_pair" "ec2_key" {
  key_name = "ec2_key"
  public_key = file("~/.ssh/ec2-key-pair.pub")
}

resource "aws_security_group" "sg1" {
  name = "web-sg1"
  description = "sg"
  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32","15.206.158.118/32","13.201.12.146/32"]

  }
  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]

  }
  ingress {
    description = "jenkins"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]

  }
  ingress {
    description = "colloborative-editor-app"
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32","13.201.12.146/32","15.206.158.118/32"]

  }
  egress {
    description = "outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_instance "Instance1" {
    ami         = "ami-00bb6a80f01f03502"
    subnet_id = "subnet-024c2b3185c14e6bd"
    security_groups = [ aws_security_group.sg1.id ]
    key_name = aws_key_pair.ec2_key.key_name
    instance_type ="t2.micro"    
    associate_public_ip_address = true     
    lifecycle {
    prevent_destroy = false 
    ignore_changes = [
      security_groups
      
    ]
  }
}

resource aws_instance "Instance2" {
    ami         = "ami-00bb6a80f01f03502"
    subnet_id = "subnet-024c2b3185c14e6bd"
    security_groups = [ aws_security_group.sg1.id ]
    key_name = aws_key_pair.ec2_key.key_name
    instance_type ="t2.micro"    
    associate_public_ip_address = true     
    lifecycle {
    prevent_destroy = false
    ignore_changes = [
      security_groups
      
    ]
  }
}
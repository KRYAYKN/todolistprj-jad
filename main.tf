terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.45.0"
    }
  }
}

provider "aws" {
  region = var.region

}

variable "region" {
  default= "us-east-1"
}
variable "key" {
  default = "jenkins-project"
}
variable "user" {
  default= "koray35"
}
resource "aws_instance" "managed-nodes" {
  ami = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  key_name= var.key
  vpc_security_group_ids= [aws_security_group.tf-sec-gr.id]
  iam_instance_profile= "jenkins-project-profile-${var.user}"
  tags = {
    Name = "jenkins-project"
  }
}
locals {
  secgr-dynamic-ports = [22,5000,5432,3000]
}

resource "aws_security_group" "tf-sec-gr" {
  name = "project-jenkins-sec-gr"

  tags = {
    Name = "project-jenkins-sec-gr"
  }

  dynamic "ingress" {
    for_each = local.secgr-dynamic-ports
    content {
    from_port        = ingress.value
    to_port          = ingress.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }


  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}
output "node_public_ip"{
   value = aws_instance.managed-nodes.public_ip
}

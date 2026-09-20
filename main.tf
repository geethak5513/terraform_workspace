terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# This lab uses the default VPC already present in most AWS accounts.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "lab_vm" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default_vpc.ids[0]
  associate_public_ip_address = true

  tags = {
    Name      = "github-actions-terraform-lab"
    ManagedBy = "Terraform"
    Purpose   = "learning"
  }
}

output "instance_id" {
  value = aws_instance.lab_vm.id
}

output "public_ip" {
  value = aws_instance.lab_vm.public_ip
}

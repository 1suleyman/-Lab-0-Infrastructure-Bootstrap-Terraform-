# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get subnets in the default VPC (we'll pick the first one)
data "aws_subnets" "default_in_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Reference existing key pair by name
data "aws_key_pair" "existing" {
  key_name = var.key_name
}

# Amazon Linux 2023 AMI lookup (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "lab_sg" {
  name_prefix = "${var.name}-sg-"
  description = "Lab SG: SSH only from your IP. Outbound allowed."
  vpc_id      = data.aws_vpc.default.id

  # SSH only from your IP
  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Outbound allowed (needed to download packages & pull images)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default_in_vpc.ids[0]
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  key_name  = data.aws_key_pair.existing.key_name

  tags = {
    Name = var.name
  }
}

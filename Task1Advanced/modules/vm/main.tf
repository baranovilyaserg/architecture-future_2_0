terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "vm" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.vm_sg.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(
      local.common_tags,
      {
        Name = "${var.instance_name}-root"
      }
    )
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring = true

  tags = merge(
    local.common_tags,
    {
      Name = var.instance_name
    }
  )

  depends_on = [aws_security_group.vm_sg]
}

resource "aws_ebs_volume" "data_volume" {
  availability_zone = aws_instance.vm.availability_zone
  size              = var.ebs_volume_size
  type              = "gp3"
  encrypted         = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.instance_name}-data"
    }
  )
}

resource "aws_volume_attachment" "data_volume_attach" {
  device_name             = "/dev/sdf"
  volume_id               = aws_ebs_volume.data_volume.id
  instance_id             = aws_instance.vm.id
  force_detach            = false
  skip_destroy            = false
  stop_instance_before_detaching = true
}

resource "aws_security_group" "vm_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} in ${var.environment}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.instance_name}-sg"
    }
  )
}

locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Module      = "vm_module"
      ManagedBy   = "Terraform"
    }
  )
}

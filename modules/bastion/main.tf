data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] 
  
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "bastion_sg" {
  name = "${var.name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH from admin IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  } 

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-bastion-sg" })
}

resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = <<-EOF
  #!/bin/bash
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y unzip curl

  # Install AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
EOF

  tags = merge(var.tags, { Name = "${var.name}-bastion" })
}
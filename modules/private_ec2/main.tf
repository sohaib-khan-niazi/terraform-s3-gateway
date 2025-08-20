data "aws_ami" "al2023" {
  most_recent = true
  owners = ["137112412989"] #Amazon
  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }  
}

resource "aws_security_group" "priv_ec2" {
  name = "${var.name}-priv-ec2-sg"
  description = "Security group for private EC2"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-priv-ec2-sg" })  
}

resource "aws_security_group_rule" "ssh_from_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.priv_ec2.id
  source_security_group_id = var.bastion_sg_id
}

resource "aws_instance" "this" {
  ami = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.priv_ec2.id]
  associate_public_ip_address = false
  key_name = var.key_name
  iam_instance_profile = var.iam_instance_profile

  # No user_data here: AL2023 already includes AWS CLI v2.

  tags = merge(var.tags, { Name = "${var.name}-priv-ec2" })    
}


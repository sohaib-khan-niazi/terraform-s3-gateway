# VPC module

module "vpc" {
  source = "../../modules/vpc"

  name = local.name
  cidr = "10.0.0.0/16"
  azs = ["${var.region}a"]

  public_subnet_cidrs = ["10.0.0.0/24"]
  private_subnet_cidrs = ["10.0.1.0/24"]

  tags = local.tags  
}

# Bastion host module

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096  
}

resource "local_file" "ssh_private_key" {
  content = tls_private_key.ssh.private_key_pem
  filename = "${path.root}/id_rsa"
  file_permission = "0600"  
}

resource "aws_key_pair" "ssh_key" {
  public_key = tls_private_key.ssh.public_key_openssh  
}

module "bastion" {
  source = "../../modules/bastion"

  name = local.name
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  ssh_ingress_cidr = var.admin_ip
  key_name = aws_key_pair.ssh_key.key_name

  tags = local.tags    
}

# S3 bucket module

module "s3" {
  source = "../../modules/s3"
  name = local.name
  tags = local.tags
}

# VPC Gateway Endpoint module

module "s3_vpce" {
  source = "../../modules/vpc_endpoint_s3"
  name = local.name
  vpc_id = module.vpc.vpc_id
  route_table_ids = [module.vpc.private_route_table_id]
  tags = local.tags   
}

# Bucket Policy: Allow access only via this VPC endpoint

resource "aws_s3_bucket_policy" "restrict_to_vpce" {
  bucket = module.s3.bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAccessOnlyFromThisVPCE"
        Effect   = "Allow"
        Principal = "*"
        Action   = ["s3:*"]
        Resource = [
          module.s3.bucket_arn,
          "${module.s3.bucket_arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = module.s3_vpce.vpc_endpoint_id
          }
        }
      }
    ]
  })  
}

# IAM_INSTANCE_PROFILE module

module "iam_ec2" {
  source = "../../modules/iam_ec2"
  name = local.name
  bucket_arn = module.s3.bucket_arn
  tags = local.tags 
}

# Private EC2 module

module "priv_ec2" {
  source = "../../modules/private_ec2"

  name = local.name
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  bastion_sg_id = module.bastion.bastion_sg_id
  iam_instance_profile = module.iam_ec2.instance_profile_name
  key_name = aws_key_pair.ssh_key.key_name
  tags = local.tags  
}
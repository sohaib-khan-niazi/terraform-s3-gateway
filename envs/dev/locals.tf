locals {
  name = "s3-gw-demo-dev"
  tags = {
    Project     = "s3-gw-demo"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

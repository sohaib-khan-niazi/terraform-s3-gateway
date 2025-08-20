# terraform-s3-gateway

Terraform project that provisions a secure AWS setup:
- **VPC** with public + private subnets  
- **Bastion host** in public subnet for SSH access  
- **Private EC2** (no public IP) in private subnet  
- **S3 bucket** for storage  
- **VPC Gateway Endpoint** for private EC2 ↔ S3 access (no internet/NAT)  
- **IAM role & instance profile** for EC2 to access S3 without access keys  

This design ensures the private EC2 can interact with S3 securely over AWS’s private network only.

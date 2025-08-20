variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-1"  
}

variable "project" {
   description = "Project name for tagging"
   type = string
   default = "s3-gateway-demo"  
}

variable "environment" {
  description = "Environment name" 
  type = string
  default = "dev"
}
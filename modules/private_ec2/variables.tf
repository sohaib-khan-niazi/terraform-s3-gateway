variable "name" {
  type = string  
}

variable "vpc_id" {
  type = string  
}

variable "subnet_id" {
  type = string
}

variable "bastion_sg_id" {
  type = string  
}

variable "iam_instance_profile" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t3.micro"  
}

variable "key_name" {
  type = string
  default = null  
}

variable "tags" {
  type = map(string) 
  default = {}    
}
variable "name" { 
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "vpc_id" { 
  type = string 
}

variable "ssh_ingress_cidr" { 
  type = string                  # e.g. "YOUR.IP.ADDR.XXX/32"
} 

variable "instance_type" {
  type = string 
  default = "t2.micro" 
}

variable "key_name" {
  type = string 
  default = null                 # optional, use SSM if null
}     

variable "tags" {
  type = map(string) 
  default = {} 
}

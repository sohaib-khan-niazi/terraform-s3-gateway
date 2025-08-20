#All the varibales will be passed from the root

variable "name" {
  type = string  # base name for tags
}

variable "cidr" {
  type = string
}

variable "azs" {
  type = list(string)  
}

variable "public_subnet_cidrs" {
  type = list(string)  
}

variable "private_subnet_cidrs" {
  type = list(string)  
}

variable "tags" {
  type = map(string)
  default = {}   
}
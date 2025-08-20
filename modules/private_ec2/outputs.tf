output "instance_id" {
  value = aws_instance.this.id  
}

output "private_ip" {
  value = aws_instance.this.private_ip  
}

output "security_group_id" {
  value = aws_security_group.priv_ec2.id  
}

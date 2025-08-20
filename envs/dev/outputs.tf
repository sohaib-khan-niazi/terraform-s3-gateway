output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip 
}

output "private_instance_ip" {
  value = module.priv_ec2.private_ip  
}
# output "id" {
#   description = "The ID of the instance"
#   value = module.dev.id 
# }

output "bastion_eip" {
  description = "bastion host eip"
  value       = module.dev.bastion_eip
}

output "k8s_private_ip" {
  description = "k8s instances privates IP"
  value       = module.dev.k8s_instances_private_ip
}

output "loadbalancer_public_ip" {
  description = "Loadbalancer instance public IP"
  value       = module.dev.loadbalancer_public_ip
}
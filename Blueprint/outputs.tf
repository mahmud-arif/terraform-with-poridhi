# VPC Output Values

# VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.myapp_vpc.vpc_id
}

# VPC CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.myapp_vpc.vpc_cidr_block
}

# VPC Private Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.myapp_vpc.private_subnets
}

# VPC Public Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.myapp_vpc.public_subnets
}

# VPC NAT gateway Public IP
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.myapp_vpc.nat_public_ips
}

# VPC AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.myapp_vpc.azs
}

# Security group outputs

output "bastion_sg_id" {
  description = "The ID of the instance"
  value       = module.public_bastion_sg.security_group_id

}

# output "k8s_sg_id" {
#   description = "The ID of the instance"
#   value       = module.k8s_instance_sg.security_group_id
# }

output "loadbalancer_sg_id" {
  description = "The ID of the instance"
  value       = module.loadbalancer_sg.security_group_id
}

# EC2 output

output "bastion_host_id" {
  description = "The ID of the bastion instance"
  value       = module.ec2_basion_host.id
}


output "bastion_eip" {
  description = "Bastion host public elastic IP"
  value       = aws_eip.bastion_eip.public_ip
}


## k8s_private_ip
output "k8s_instances_private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = { for ec2private in module.k8s_instances : ec2private.tags_all["Name"] => ec2private.private_ip }
}

output "loadbalancer_public_ip" {
  description = "Loadbalancer Public IP"
  value       = module.loadbalancer_instance.public_ip
}
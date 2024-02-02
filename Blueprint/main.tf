module "myapp_vpc" {
  source          = "../modules/vpc"
  name            = "${var.environment}-${var.vpc_name}"
  cidr            = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks
  azs             = var.vpc_availability_zones

  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  enable_dns_hostnames   = var.vpc_dns_hostname
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_dns_support     = var.enable_dns_support
  tags                   = var.common_tags
}


module "public_bastion_sg" {
  depends_on  = [module.myapp_vpc]
  source      = "../modules/security_group"
  name        = "${var.environment}-${var.bastion_sg}"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.myapp_vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
}


module "ec2_basion_host" {
  depends_on = [module.myapp_vpc, module.public_bastion_sg]
  source     = "../modules/ec2_instance"

  name              = "${var.environment}-${var.bastion_instance.name}"
  ami               = var.bastion_instance.ami
  instance_type     = var.bastion_instance.instance_type
  root_block_device = var.bastion_instance.root_block_device != null ? var.bastion_instance.root_block_device : []
  key_name          = var.bastion_instance.key_name
  #monitoring             = true
  subnet_id              = element(module.myapp_vpc.public_subnets, 0)
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  # tags                   = var.common_tags
}

resource "aws_eip" "bastion_eip" {
  depends_on = [module.ec2_basion_host, module.myapp_vpc]
  tags       = var.common_tags
  instance   = module.ec2_basion_host.id
  domain     = "vpc"
}

module "k8s_master_sg" {
  depends_on  = [module.myapp_vpc]
  source      = "../modules/security_group"
  name        = "${var.environment}-${var.k8s_master_sg_name}"
  description = "Security Group k3s master"
  vpc_id      = module.myapp_vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = var.k8s_master_ingress_rules
  ingress_cidr_blocks = [module.myapp_vpc.vpc_cidr_block]

  ingress_with_cidr_blocks = var.k8s_master_ingress_with_cidr_blocks
  # Egress Rule - all-all open
  egress_rules = var.k8s_master_egress_rules
}

module "k8s_worker_sg" {
  depends_on  = [module.myapp_vpc]
  source      = "../modules/security_group"
  name        = "${var.environment}-${var.k8s_worker_sg_name}"
  description = "Security Group k3s  worker nodes"
  vpc_id      = module.myapp_vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = var.k8s_worker_ingress_rules
  ingress_cidr_blocks = [module.myapp_vpc.vpc_cidr_block]

  ingress_with_cidr_blocks = var.k8s_worker_ingress_with_cidr_blocks
  # Egress Rule - all-all open
  egress_rules = var.k8s_worker_egress_rules
}

locals {
  k8s_nodes_security_groups = {
    "master" = module.k8s_master_sg.security_group_id,
    "worker" = module.k8s_worker_sg.security_group_id
  }
}

# Create EC2 instances using the module and for_each loop
module "k8s_instances" {
  depends_on = [module.myapp_vpc, module.k8s_master_sg, module.k8s_worker_sg]
  source     = "../modules/ec2_instance"

  for_each = {
    for idx, instance in var.k8s_instances : idx => {
      instance  = instance
      subnet_id = module.myapp_vpc.private_subnets[idx % length(module.myapp_vpc.private_subnets)]
      security_group = [
        for sg in instance.security_group : local.k8s_nodes_security_groups[sg]
      ]
    }
  }

  name                   = "${var.environment}-k8s-instance-${each.value.instance.name}"
  instance_type          = each.value.instance.instance_type
  ami                    = each.value.instance.ami
  subnet_id              = each.value.subnet_id
  key_name               = each.value.instance.key_name
  root_block_device      = each.value.instance.root_block_device != null ? each.value.instance.root_block_device : []
  vpc_security_group_ids = each.value.security_group

  # tags = var.common_tags
}

module "loadbalancer_sg" {
  depends_on  = [module.myapp_vpc]
  source      = "../modules/security_group"
  name        = "${var.environment}-${var.loadbalancer_sg}"
  description = "Security Group for nginx loadbalancer"
  vpc_id      = module.myapp_vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = [module.myapp_vpc.vpc_cidr_block]

  ingress_with_cidr_blocks = [
    {
      rule       = "http-80-tcp"
      cidr_block = "0.0.0.0/0"
    }
  ]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
}


module "loadbalancer_instance" {
  depends_on = [module.myapp_vpc]
  source     = "../modules/ec2_instance"

  name                        = "${var.environment}-${var.loadbalancer_instance.name}"
  ami                         = var.loadbalancer_instance.ami
  instance_type               = var.loadbalancer_instance.instance_type
  associate_public_ip_address = var.loadbalancer_instance.associate_public_ip_address
  root_block_device           = var.loadbalancer_instance.root_block_device != null ? var.loadbalancer_instance.root_block_device : []
  key_name                    = var.loadbalancer_instance.key_name
  #monitoring             = true
  subnet_id              = element(module.myapp_vpc.public_subnets, 1)
  vpc_security_group_ids = [module.loadbalancer_sg.security_group_id]
}
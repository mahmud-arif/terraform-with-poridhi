terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }
}

locals {
  project_name = "poridhi"
  key_name     = "terraform-key"
  environment  = "dev"
  common_tags = {
    environment = local.environment
    Name        = local.project_name
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



module "dev" {
  environment = local.environment
  common_tags = local.common_tags
  ## vpc settings
  source                     = "../../Blueprint"
  vpc_name                   = "my-vpc"
  vpc_availability_zones     = ["us-east-1a", "us-east-1b"]
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidr_blocks  = ["10.0.4.0/24", "10.0.5.0/24"]
  vpc_enable_nat_gateway     = true
  vpc_single_nat_gateway     = true
  enable_dns_support         = true
  vpc_dns_hostname           = true

  ## bastion sg Settings
  bastion_sg = "bastion-sg"

  ## bastion host settings
  bastion_instance = {
    name          = "bastion-host"
    instance_type = "t2.small"
    ami           = data.aws_ami.ubuntu.id
    key_name      = local.key_name
    root_block_device = [{
      volume_size = 15
    }]
    subnet_id      = element(module.dev.public_subnets, 0)
    security_group = [module.dev.bastion_sg_id]
  }

  ## k8s sg settings
  k8s_sg = "k8s-sg"

  ## k8s ec2 settings
  k8s_instances = [{
    name          = "master"
    instance_type = "t2.medium"
    ami           = data.aws_ami.ubuntu.id
    subnet_id     = element(module.dev.private_subnets, 0)
    key_name      = local.key_name
    # root_block_device = number
    security_group = [module.dev.k8s_sg_id]
    },
    {
      name          = "worker-1"
      instance_type = "t2.medium"
      ami           = data.aws_ami.ubuntu.id
      subnet_id     = element(module.dev.private_subnets, 1)
      key_name      = local.key_name

      security_group = [module.dev.k8s_sg_id]
    },
    {
      name          = "worker-2"
      instance_type = "t2.medium"
      ami           = data.aws_ami.ubuntu.id
      subnet_id     = element(module.dev.private_subnets, 1)
      key_name      = local.key_name
      # root_block_device = number
      security_group = [module.dev.k8s_sg_id]
  }]

  ## loadbalancer security group settings
  loadbalancer_sg = "loadbalancer-sg"

  ## loadbalancer ec2 settings
  ## bastion host settings
  loadbalancer_instance = {
    name                        = "loadbalancer"
    instance_type               = "t2.small"
    ami                         = data.aws_ami.ubuntu.id
    key_name                    = local.key_name
    associate_public_ip_address = true
    subnet_id                   = element(module.dev.public_subnets, 1)
    security_group              = [module.dev.loadbalancer_sg_id]
  }
}
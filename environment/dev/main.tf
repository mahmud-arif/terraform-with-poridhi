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
  vpc_cidr_block = "10.0.0.0/16"
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
    # security_group = [module.dev.bastion_sg_id]
  }

    ## k8s master node sg settings
  k8s_master_sg_name = "k8s-master-sg"
  k8s_master_ingress_rules = ["ssh-tcp", "kubernetes-api-tcp", "etcd-client-tcp"]
  k8s_master_ingress_with_cidr_blocks = [
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 8472
      to_port     = 8472
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 51820
      to_port     = 51821
      protocol    = "udp"
      cidr_blocks = "10.0.0.0/16"
  }]
  k8s_master_egress_rules = ["all-all"]

  ## k8s worker node sg settings

  k8s_worker_sg_name = "k8s-worker-sg"
  k8s_worker_ingress_rules = ["ssh-tcp", "kubernetes-api-tcp", "etcd-client-tcp"]
  k8s_worker_ingress_with_cidr_blocks = [
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 51820
      to_port     = 51821
      protocol    = "udp"
      cidr_blocks = "10.0.0.0/16"
  }]
  k8s_worker_egress_rules = ["all-all"]

  ## k8s ec2 settings
  k8s_instances = [{
    name           = "master"
    instance_type  = "t2.medium"
    ami            = data.aws_ami.ubuntu.id
    key_name       = local.key_name
    security_group = ["master"]
    # root_block_device = number
    },
    {
      name           = "worker-1"
      instance_type  = "t2.medium"
      ami            = data.aws_ami.ubuntu.id
      key_name       = local.key_name
      security_group = ["worker"]
    },
    {
      name           = "worker-2"
      instance_type  = "t2.medium"
      ami            = data.aws_ami.ubuntu.id
      key_name       = local.key_name
      security_group = ["worker"]
      # root_block_device = number
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
  }
}
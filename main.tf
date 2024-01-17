terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }
}

# Configure AWS provider with your credentials
provider "aws" {
  region = "us-east-1" # Change to your desired region
  # profile    = "poridhi"
}

# Create a VPC
module "vpc_module" {
  source   = "./vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my_cluster_vpc"
  azs      = ["us-east-1a", "us-east-1b"]
  public_subnet_configs = [
    {
      subnet_cidr_blocks = "10.0.2.0/24",
      name               = "private_subnet",
      allow_public_ip    = true,
      availability_zone  = "us-east-1b"
  }]
  private_subnet_configs = [
    {
      subnet_cidr_blocks = "10.0.1.0/24",
      name               = "public_subnet",
      availability_zone  = "us-east-1a"
  }]
  igw_name           = "my_igw"
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "k8-ssh"
  public_key = file("/Users/mahmud/.ssh/id_rsa.pub")
}


module "security_rules_k8s" {
  source              = "./security_group"
  security_group_name = "k8s-security-group"
  vpc_id              = module.vpc_module.vpc_id
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 2379
      to_port     = 2380
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 8472
      to_port     = 8472
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      from_port   = 51820
      to_port     = 51821
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

module "k8s_node" {
  source = "./ec2_instance"
  instances = [
    {
      name              = "k8s-master",
      instance_type     = "t2.medium"
      ami               = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
      subnet_id         = module.vpc_module.private_subnet_ids[0]
      key_name          = resource.aws_key_pair.ssh_key.key_name
      root_block_device = 20
      security_group    = [module.security_rules_k8s.security_group_id]
    },
    {
      name              = "k8s-worker-1",
      instance_type     = "t2.medium"
      ami               = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
      subnet_id         = module.vpc_module.private_subnet_ids[0]
      key_name          = resource.aws_key_pair.ssh_key.key_name
      root_block_device = 20
      security_group    = [module.security_rules_k8s.security_group_id]
    },
    {
      name              = "k8s-worker-2",
      instance_type     = "t2.medium"
      ami               = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
      subnet_id         = module.vpc_module.private_subnet_ids[0]
      key_name          = resource.aws_key_pair.ssh_key.key_name
      root_block_device = 20
      security_group    = [module.security_rules_k8s.security_group_id]
    }
  ]

  depends_on = [module.security_rules_k8s]
}



module "security_group_bashtion" {
  source              = "./security_group"
  security_group_name = "bastion-security-group"
  vpc_id              = module.vpc_module.vpc_id
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "security_group_loadbalancer" {
  source              = "./security_group"
  security_group_name = "loadbalancer-security-group"
  vpc_id              = module.vpc_module.vpc_id
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "other_nodes" {
  source = "./ec2_instance"
  instances = [
    {
      name              = "bastionHost",
      instance_type     = "t2.small"
      ami               = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
      subnet_id         = module.vpc_module.public_subnet_ids[0]
      key_name          = resource.aws_key_pair.ssh_key.key_name
      root_block_device = 10
      security_group    = [module.security_group_bashtion.security_group_id]
    },
    {
      name              = "loadbalancer"
      instance_type     = "t2.small"
      ami               = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
      subnet_id         = module.vpc_module.public_subnet_ids[0]
      key_name          = resource.aws_key_pair.ssh_key.key_name
      root_block_device = 15
      security_group    = [module.security_group_loadbalancer.security_group_id]
    }
  ]
}















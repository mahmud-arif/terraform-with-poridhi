# VPC Input Variables

# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "my-k3s-vpc"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

# VPC Availability Zones

variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}


# VPC Public Subnets
variable "public_subnet_cidr_blocks" {
  description = "VPC Public Subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# VPC Private Subnets
variable "private_subnet_cidr_blocks" {
  description = "VPC Private Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
  default     = true
}

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
  default     = true
}

variable "vpc_dns_hostname" {
  description = "Enable dns hostname"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Deploy nat gateway per az"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Enable dns support"
  type        = bool
  default     = true
}


# Security group variables

variable "bastion_sg" {
  description = "Bastion instance security group Name"
  type        = string
  default     = "bastion-sg"
}


# master Security group variables

variable "k8s_master_sg_name" {
  description = "k8s master instance security group Name"
  type        = string
  default     = "k8s-master-sg"
}

variable "k8s_master_ingress_rules" {
  description = "k8s master default ingerss rule only with name example ssh-tcp"
  type        = list(string)
}


variable "k8s_master_ingress_with_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
}

variable "k8s_master_egress_rules" {
  type    = list(string)
  default = ["all-all"]
}


# k8s worker node security group

variable "k8s_worker_sg_name" {
  description = "k8s worker instance security group Name"
  type        = string
  default     = "k8s-worker-sg"
}

variable "k8s_worker_ingress_rules" {
  description = "k8s worker default ingerss rule only with name example ssh-tcp"
  type        = list(string)
}


variable "k8s_worker_ingress_with_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
}

variable "k8s_worker_egress_rules" {
  type    = list(string)
  default = ["all-all"]
}




variable "loadbalancer_sg" {
  description = "loadbalancer instance security group Name"
  type        = string
  default     = "loadbalancer-sg"
}

# EC2 vairables 

variable "bastion_instance" {
  description = "Configuration for a bastion instance."
  type = object({
    name          = string
    instance_type = string
    ami           = string
    key_name      = string
    root_block_device = optional(list(object({
      encrypted   = optional(bool)
      volume_type = optional(string)
      throughput  = optional(number)
      volume_size = optional(number)
      tags        = optional(map(string))
    })))
  })
}


variable "k8s_instances" {
  description = "Configuration for k8s instances."
  type = list(object({
    name          = string
    instance_type = string
    ami           = string
    key_name      = string
    root_block_device = optional(list(object({
      encrypted   = optional(bool)
      volume_type = optional(string)
      throughput  = optional(number)
      volume_size = optional(number)
      tags        = optional(map(string))
    })))
    security_group = list(string)
  }))
}

variable "loadbalancer_instance" {
  description = "Configuration for a Loadbalancer instance."
  type = object({
    name                        = string
    instance_type               = string
    ami                         = string
    associate_public_ip_address = string
    key_name                    = string
    root_block_device = optional(list(object({
      encrypted   = optional(bool)
      volume_type = optional(string)
      throughput  = optional(number)
      volume_size = optional(number)
      tags        = optional(map(string))
    })))
  })
}
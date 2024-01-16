variable "vpc_cidr" {
  type = string

}

variable "vpc_name" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_configs" {
  type = list(object({
    subnet_cidr_blocks = string,
    name               = string,
    allow_public_ip    = bool,
    availability_zone  = string
  }))
}

variable "private_subnet_configs" {
  type = list(object({
    subnet_cidr_blocks = string,
    name               = string,
    availability_zone  = string
  }))
}

variable "igw_name" {
  type = string
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "single_nat_gateway" {
  type    = bool
  default = null
}


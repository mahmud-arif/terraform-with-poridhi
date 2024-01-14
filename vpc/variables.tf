variable "vpc_cidr" {
  type = string

}

variable "vpc_name" {
  type = string
}

variable "subnet_configs" {
  type = list(object({
    subnet_cidr_blocks = string,
    name               = string,
    allow_public_ip    = bool,
    availability_zone  = string
  }))
}

variable "igw_name" {
  type = string
}

variable "nat_gateway_for_subnet" {
  type = string
}

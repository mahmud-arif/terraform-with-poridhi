variable "security_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  description = "List of ingress rules with port and cidr_blocks"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
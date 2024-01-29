# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common Tags value for resources"
  type = object({
    environment = string
    Name        = string
  })
}
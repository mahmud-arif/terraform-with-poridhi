variable "instances" {
  description = "List of instances with details"
  type = list(object({
    name              = string
    subnet_id         = string
    instance_type     = string
    ami               = string
    key_name          = string
    root_block_device = number
    security_group    = list(string)
  }))

}
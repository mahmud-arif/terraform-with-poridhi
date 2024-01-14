output "private_subnet_id" {
  value = [for v in var.subnet_configs : v.]
}
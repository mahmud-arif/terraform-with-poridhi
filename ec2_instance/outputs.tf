output "instance_public_ips" {
  value = { for instance in aws_instance.instances : instance.tags["Name"] => instance.public_ip if instance.public_ip != null }
}



output "instance_private_ips" {
  value = [for instance in aws_instance.instances : { name = instance.tags["Name"], private_ip = instance.private_ip }]
}

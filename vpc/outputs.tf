# output "private_subnet_id" {
#   value = [for subnet in resource.aws_subnet.public_subnet : subnet.id if subnet.map_public_ip_on_launch != true]
# }

# output "public_subnet_id" {
#   value = [for subnet in resource.aws_subnet.public_subnet : subnet.id if subnet.map_public_ip_on_launch == true]
# }
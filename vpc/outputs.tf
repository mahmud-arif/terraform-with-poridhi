output "vpc_id" {
  value = resource.aws_vpc.my_vpc.id
}

output "private_subnet_ids" {
  value = [for subnet in resource.aws_subnet.private_subnet : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in resource.aws_subnet.public_subnet : subnet.id]
}
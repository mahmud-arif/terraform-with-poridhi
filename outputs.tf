output "k8s_node_private_ips" {
  value = module.k8s_node.instance_private_ips
}

output "other_nodes_public_ips" {
  value = module.other_nodes.instance_private_ips
}
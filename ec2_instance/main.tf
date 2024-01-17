resource "aws_instance" "instances" {
  count         = length(var.instances)
  subnet_id     = var.instances[count.index].subnet_id
  ami           = var.instances[count.index].ami
  instance_type = var.instances[count.index].instance_type
  key_name      = var.instances[count.index].key_name

  root_block_device {
    volume_size = var.instances[count.index].root_block_device
  }

  security_groups = var.instances[count.index].security_group

  tags = {
    Name = var.instances[count.index].name
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr # Change to your desired CIDR block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_configs)
  vpc_id                  = resource.aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_configs[count.index].subnet_cidr_blocks
  availability_zone       = var.public_subnet_configs[count.index].availability_zone
  map_public_ip_on_launch = var.public_subnet_configs[count.index].allow_public_ip
  tags = {
    Name = var.public_subnet_configs[count.index].name
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_configs)
  vpc_id            = resource.aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_configs[count.index].subnet_cidr_blocks
  availability_zone = var.private_subnet_configs[count.index].availability_zone
  tags = {
    Name = var.private_subnet_configs[count.index].name
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = resource.aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
  }
}

locals {
  create_public_subnet = length(var.public_subnet_configs) > 0
}


resource "aws_route_table" "public" {
  count = local.create_public_subnets ? 1 : 0

  vpc_id = var.vpc_id

  tags = { "Name" = "public-route-table" }
}

resource "aws_route_table_association" "public" {
  count = local.create_public_subnets ? length(var.public_subnet_configs) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}



resource "aws_route" "public_internet_gateway" {
  count = local.create_public_subnets && var.igw_name ? 1 : 0

  route_table_id         = resource.aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = resource.aws_internet_gateway.my_igw.id

  timeouts {
    create = "5m"
  }
}


locals {
  create_private_subnets = length(var.private_subnet_configs) > 0
}


# There are as many routing tables as the number of NAT gateways
resource "aws_route_table" "private" {
  count = local.create_private_subnets ? local.nat_gateway_count : 0

  vpc_id = var.vpc_id

  tags = {
    "Name" = var.single_nat_gateway ? "private-route-table" : format(
      "private-route-table-%s",
      element(var.azs, count.index),
    )
  }
}

resource "aws_route_table_association" "private" {
  count = local.create_private_subnets ? length(var.private_subnet_configs) : 0

  subnet_id = element(resource.aws_subnet.private_subnet[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}



locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.azs)
  nat_gateway_ips   = try(resource.aws_eip.nat[*].id, [])
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = {
    "Name" = format(
      "my-eip-%s",
      element(var.azs, var.single_nat_gateway ? 0 : count.index)
    )
  }

  depends_on = [resource.aws_internet_gateway.my_igw]
}



resource "aws_nat_gateway" "my_nat_gateway" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    resource.aws_subnet.public_subnet[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = {
    "Name" = format(
      "my-nat-gateway-%s",
      element(var.azs, var.single_nat_gateway ? 0 : count.index),
    )
  }

  depends_on = [resource.aws_internet_gateway.my_igw]
}



resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(resource.aws_route_table.private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(resource.aws_nat_gateway.my_nat_gateway[*].id, count.index)

  timeouts {
    create = "5m"
  }
}


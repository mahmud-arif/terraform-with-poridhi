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

resource "aws_internet_gateway" "my-igw" {
  vpc_id = resource.aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
  }
}


resource "aws_nat_gateway" "my_nat_gateway" {
  # connectivity_type = "private"
  count     = var.single_nat_gateway == true ? 1 : length(var.public_subnet_configs)
  subnet_id = var.single_nat_gateway == true ? resource.aws_subnet.public_subnet[0].id : resource.aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "my_nat_gateway_${count.index}"
  }
}


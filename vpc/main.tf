resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr # Change to your desired CIDR block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "public_subnet" {
  count             = length(var.subnet_configs)
  vpc_id            = resource.aws_vpc.my_vpc.id
  cidr_block        = var.subnet_configs[count.index].subnet_cidr_blocks
  availability_zone = var.subnet_configs[count.index].availability_zone
  # Change to your desired availability zone
  map_public_ip_on_launch = var.subnet_configs[count.index].allow_public_ip
  tags = {
    Name = var.subnet_configs[count.index].name
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = resource.aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = var.my_nat_gateway
  }
}
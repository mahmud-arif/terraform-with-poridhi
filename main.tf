terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }
}

# Configure AWS provider with your credentials
provider "aws" {
  region = "us-east-1" # Change to your desired region
  # profile    = "poridhi"
}

# Create a VPC
module "vpc_module" {
  source   = "./vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my_cluster_vpc"
  subnet_configs = [
    {
      subnet_cidr_blocks = "10.0.1.0/24",
      name               = "public_subnet",
      allow_public_ip    = true,
      availability_zone  = "us-east-1a"
    },
    {
      subnet_cidr_blocks = "10.0.2.0/24",
      name               = "private_subnet",
      allow_public_ip    = false,
      availability_zone  = "us-east-1b"
  }]
  igw_name = "my_igw"
  nat_gateway_for_subnet = 
}

# Create a subnet within the VPC
# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.my_vpc.id
#   cidr_block              = "10.0.0.0/24" # Change to your desired CIDR block within your VPC range
#   availability_zone       = "us-east-1a"  # Change to your desired availability zone
#   map_public_ip_on_launch = true
#       tags = {
#        Name = "public-subnet"
#     }
# }


# resource "aws_internet_gateway" "my-igw" {
#   vpc_id = aws_vpc.my_vpc.id

#   tags = {
#     Name: "k8-igw"
#   }
# }

# resource "aws_route_table" "public-route-table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = aws_internet_gateway.my-igw.id


#     }

# }




# resource "aws_route_table_association" "public-rtb-subnet" {
#   subnet_id = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public-route-table.id
# }


# resource "aws_subnet" "private_subnet" {
#   vpc_id                  = aws_vpc.my_vpc.id
#   cidr_block              = "10.0.4.0/24" 
#   availability_zone       = "us-east-1b"  
#       tags = {
#         Name = "private-subnet"
#     }
# }



# resource "aws_nat_gateway" "my_nat_gateway" {
#   subnet_id     = aws_subnet.public_subnet.id

#   tags = {
#     Name = "my-nat-gateway"
#   }
# }

# # Route table for private subnet with NAT Gateway route
# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.my_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
#   }

#   tags = {
#     Name = "private-route-table"
#   }
# }

# resource "aws_route_table_association" "private_subnet_association" {
#   subnet_id      = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.private_route_table.id
# }



# resource "aws_security_group" "master_sg" {
#   name        = "master"
#   description = "Security group for master instance"
#   vpc_id = aws_vpc.my_vpc.id

#   # Ingress rule for SSH (port 22)
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # Be cautious with this setting; it allows SSH access from any IP
#   }
#   # Ingress rule for port 6443
#   ingress {
#     from_port   = 6443
#     to_port     = 6443
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # You can restrict this to specific IPs if needed
#   }

#   # Ingress rule for ports 2379-2380
#   ingress {
#     from_port   = 2379
#     to_port     = 2380
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # You can restrict this to specific IPs if needed
#   }

#   # Ingress rule for ports 10250-10260
#   ingress {
#     from_port   = 10250
#     to_port     = 10260
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # You can restrict this to specific IPs if needed
#   }



#     ingress {
#     from_port   = 6782
#     to_port     = 6782
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # You can restrict this to specific IPs if needed
#   }

#   # Egress rule to allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "master-sg"
#   }
# }
# #
# resource "aws_security_group" "worker_sg" {
#   name        = "worker"
#   description = "Security group for worker instances"
#   vpc_id = aws_vpc.my_vpc.id
#   # Ingress rule for SSH (port 22)
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # Be cautious with this setting; it allows SSH access from any IP
#   }

#   # Ingress rule for port 10250
#   ingress {
#     from_port   = 10250
#     to_port     = 10250
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # You can restrict this to specific IPs if needed
#   }

#   # Ingress rule for ports 30000-32767
#   ingress {
#     from_port   = 30000
#     to_port     = 32767
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # You can restrict this to specific IPs if needed
#   }



#   # Egress rule to allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "worker-sg"
#   }
# }

# resource "aws_key_pair" "ssh-key" {
#   key_name   = "k8-ssh"
#   public_key = file("/Users/mahmud/.ssh/id_rsa.pub")
# }

# # Launch EC2 instances
# resource "aws_instance" "master" {
#   ami           = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
#   instance_type = "t2.medium"
#   subnet_id     = aws_subnet.private_subnet.id
#   key_name      = aws_key_pair.ssh-key.key_name
#   vpc_security_group_ids  = [aws_security_group.master_sg.id]
#   root_block_device {
#     volume_size = 20
#   }
#   tags = {
#     Name = "master"
#   }
# }

# resource "aws_instance" "worker1" {
#   ami           = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
#   instance_type = "t2.medium"
#   subnet_id     = aws_subnet.private_subnet.id
#   key_name      = aws_key_pair.ssh-key.key_name
#   security_groups = [aws_security_group.worker_sg.id]
#   root_block_device {
#     volume_size = 20
#   }
#   tags = {
#     Name = "worker1"
#   }
# }

# resource "aws_instance" "worker2" {
#   ami           = "ami-053b0d53c279acc90" # Ubuntu 20.04 LTS AMI ID (Update with the latest AMI ID)
#   instance_type = "t2.medium"
#   subnet_id     = aws_subnet.private_subnet.id
#   key_name      = aws_key_pair.ssh-key.key_name
#   security_groups = [aws_security_group.worker_sg.id]
#   root_block_device {
#     volume_size = 20
#   }
#   tags = {
#     Name = "worker2"
#   }
# }


# output "instance_private_ips" {
#   value = [
#     aws_instance.master.private_ip,
#     aws_instance.worker1.private_ip,
#     aws_instance.worker2.private_ip,
#     # Add more instances as needed
#   ]
# }
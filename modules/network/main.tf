################################################################################
# VPC
################################################################################

resource "aws_vpc" "aws_vpc_company" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge({ "ResourceName" = "vpc-${var.name}" }, var.tags)
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "aws_internet_gateway_company" {
  #count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0
  count = var.create_vpc && var.create_igw ? 1 : 0

  vpc_id = aws_vpc.aws_vpc_company[0].id
  tags   = merge({ "ResourceName" = "igw-${var.name}" }, var.tags)

}

###### Nat Gateway ######
resource "aws_eip" "aws_eip_nat_gateway" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "aws_nat_gateway" {
  allocation_id     = aws_eip.aws_eip_nat_gateway.id
  subnet_id         = var.public_subnet_cidrs[0]
  connectivity_type = var.connectivity_type #"public" #"private"

  tags = merge({ "ResourceName" = "${var.name}-natgw" }, var.tags)

}

##### Route subnet private ######

resource "aws_route_table" "aws_route_table_private" {
  vpc_id = aws_vpc.aws_vpc_company[0].id

}

resource "aws_route" "private_routes" {
  route_table_id         = aws_route_table.aws_route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.aws_nat_gateway.id
}

resource "aws_route_table_association" "assoc_private_routes" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(var.private_subnet_cidrs, count.index)
  route_table_id = aws_route_table.aws_route_table_private.id
}

##### Route subnet public  ####

resource "aws_route_table" "aws_route_table_public" {
  vpc_id = aws_vpc.aws_vpc_company[0].id
}

resource "aws_route" "aws_route_public" {
  route_table_id         = aws_route_table.aws_route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.aws_internet_gateway_company[0].id
}

resource "aws_route_table_association" "aws_route_table_association_public" {
count = length(var.public_subnet_cidrs)
  subnet_id      = element(var.public_subnet_cidrs, count.index)
  route_table_id = aws_route_table.aws_route_table_public.id
}

##### private subnet ####


resource "aws_subnet" "private_subnets" {
 count             = length(var.private_subnet_cidrs)
 vpc_id            = aws_vpc.aws_vpc_company[0].id
 cidr_block        = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Private-Subnet-${count.index + 1}"
 }
}



##### public subnet ####

resource "aws_subnet" "public_subnets" {
 count             = length(var.public_subnet_cidrs)
 vpc_id            = aws_vpc.aws_vpc_company[0].id
 cidr_block        = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}

### sg para alb y ecs

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.aws_vpc_company[0].id
  
}



resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.aws_vpc_company[0].id
  
}


resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.app_name}-redis-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id
}

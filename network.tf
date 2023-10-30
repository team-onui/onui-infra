resource "aws_vpc" "vpc" {
  assign_generated_ipv6_cidr_block     = false
  cidr_block                           = "10.0.0.0/24"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"

  tags = {
    Name = "${var.app_name}-VPC"
    name = "onui"
  }
}

data "aws_availability_zones" "available" {
}

resource "aws_subnet" "public" {
  map_public_ip_on_launch = true
  vpc_id            = aws_vpc.vpc.id
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${data.aws_availability_zones.available.names[count.index]}"
    name = "onui"
  }
}

resource "aws_subnet" "private" {
  map_public_ip_on_launch = false
  vpc_id            = aws_vpc.vpc.id
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${data.aws_availability_zones.available.names[count.index]}"
    name = "onui"
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app_name}-igw"
    name = "onui"
  }
}

resource "aws_route" "internet_access" {
  route_table_id          = aws_vpc.vpc.main_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.igw.id
}

resource "aws_eip" "nat-eip" {
  count       = var.az_count
  depends_on  = [aws_internet_gateway.igw]
  tags = {
    Name = "onui-natgw-eip"
  }
}

# NAT 게이트웨이 생성
resource "aws_nat_gateway" "nat-gw" {
  depends_on = [aws_eip.nat-eip, aws_internet_gateway.igw]
  subnet_id     = aws_subnet.public[0].id
  connectivity_type = "private"

  tags = {
    Name = "${var.app_name}-nat-gw"
    name = "onui"
  }
}

# public routing
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
    name = "onui"
  }
}

# private routing
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-rt"
    name = "onui"
  }
}

resource "aws_route_table_association" "to-public" {
  count = length(aws_subnet.public)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public-rt.*.id, count.index)
}

resource "aws_route_table_association" "to-private" {
  count = length(aws_subnet.private)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}
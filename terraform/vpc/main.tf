
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw_main"
  }
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc   = true
  tags = {
    Name = "eip_natgw_${format("%03d", count.index + 1)}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)
  depends_on = [
    aws_vpc.main
  ]

  tags = {
    Name = "subnet_private_${format("%03d", count.index + 1)}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true
  depends_on = [
    aws_vpc.main
  ]

  tags = {
    Name = "subnet_public_${format("%03d", count.index + 1)}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.private_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [
    aws_eip.nat,
    aws_subnet.public
  ]

  tags = {
    Name = "natgw_${format("%03d", count.index + 1)}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  depends_on = [
    aws_internet_gateway.main
  ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id
  depends_on = [
    aws_subnet.private,
    aws_vpc.main,
    aws_nat_gateway.main
  ]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }

  tags = {
    Name = "rt_private_${format("%03d", count.index + 1)}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  depends_on = [
    aws_subnet.private,
    aws_route_table.private
  ]
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
  depends_on = [
    aws_subnet.public,
    aws_route_table.public
  ]
}

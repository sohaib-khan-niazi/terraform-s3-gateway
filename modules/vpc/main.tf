resource "aws_vpc" "this" {
  cidr_block = var.cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {Name = "${var.name}-vpc"})
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {Name = "${var.name}-igw"})
}

# for_each loops over each subnet CIDR from var.public_subnet_cidrs.
# each.key = index (0,1,2...), each.value = the actual CIDR block.
# cidr_block uses each.value, availability_zone picks AZ by index from var.azs.
# min() ensures if there are more subnets than AZs, extra subnets go into the last AZ.

resource "aws_subnet" "public" {
  for_each = { for i, cidr in var.public_subnet_cidrs : i => cidr}
  
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = var.azs[min(tonumber(each.key), length(var.azs)-1)]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = { for i, cidr in var.private_subnet_cidrs : i => cidr}

  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = var.azs[min(tonumber(each.key), length(var.azs)-1)]
  map_public_ip_on_launch = true  

  tags = merge(var.tags, {
    Name = "${var.name}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, { Name = "${var.name}-public-rt"})  
}

resource "aws_route" "public_inet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id  
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id  
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-private-rt" })
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id  
}
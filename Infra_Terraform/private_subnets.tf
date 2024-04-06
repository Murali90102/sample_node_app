########################################
######    private-SUBNET
########################################
resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment}-private-subnet-${count.index}"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    private- ROUTE TABLE
# ########################################
resource "aws_route_table" "private-rt" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
  tags = {
    "Name" = "${var.environment}-private-route-table-${count.index}"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    ATTACH ROUTE TABLE TO SUBNET
# ########################################
resource "aws_route_table_association" "rta-private-sub" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-rt[count.index].id
}

# ########################################
# ######    NAT GATEWAY
# ########################################
resource "aws_eip" "natgw_elastic_ip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.natgw_elastic_ip.id
  subnet_id     = aws_subnet.public-subnet[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    "Name"        = "${var.environment}-nat-gw"
    "Environment" = "${var.environment}"
  }
}

resource "aws_route" "private_nat_gateway" {
  count                  = length(var.private_subnet_cidr)
  route_table_id         = aws_route_table.private-rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

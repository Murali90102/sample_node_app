########################################
######    SUBNET
########################################
resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet-${count.index}"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    PUBLIC ROUTE TABLE
# ########################################
resource "aws_route_table" "public-rt" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "${var.environment}-public-route-table-${count.index}"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    ATTACH ROUTE TABLE TO SUBNET
# ########################################
resource "aws_route_table_association" "rta-sub" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt[count.index].id
}
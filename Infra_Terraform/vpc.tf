########################################
######    VPC
########################################
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.environment}-vpc"
    "Environment" = "${var.environment}"
  }
}


########################################
######    INTERNET GATEWAY
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]
  tags = {
    "Name" = "${var.environment}-igw"
    "Environment" = "${var.environment}"
  }
}




# ########################################
# ######    SECURITY GROUP
# ########################################
resource "aws_security_group" "sg" {

  name = "${var.environment}-demo-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = var.security_group_open_port[0]
    to_port   = var.security_group_open_port[1]
    protocol  = "tcp"
    description = "Allow workstation IP"
    cidr_blocks = [local.workstation_external_ip]   ## YOUR EXTERNAL IP WILL BE ADDED
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.environment}-sg"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    PRIVATE SECURITY GROUP
# ########################################

resource "aws_security_group" "private-sg" {

  name = "${var.environment}-demo-private-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    description = "Allow all"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.environment}-private-sg"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    Jenkins SECURITY GROUP
# ########################################

resource "aws_security_group" "sg-jenkins" {

  name = "${var.environment}-demo-jenkins-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    description = "Allow workstation IP"
    cidr_blocks = [local.workstation_external_ip]   ## YOUR EXTERNAL IP WILL BE ADDED
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.environment}-jenkins-sg"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    SSH SECURITY GROUP
# ########################################

resource "aws_security_group" "sg-ssh" {

  name = "${var.environment}-demo-ssh-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    description = "Allow workstation IP"
    cidr_blocks = [local.workstation_external_ip]   ## YOUR EXTERNAL IP WILL BE ADDED
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.environment}-ssh-sg"
    "Environment" = "${var.environment}"
  }
}

# ########################################
# ######    HTTP-HTTPS SECURITY GROUP
# ########################################
resource "aws_security_group" "sg-http-https" {

  name = "${var.environment}-demo-http-https-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    description = "Allow ALL IP"
    cidr_blocks = ["0.0.0.0/0"]   
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    description = "Allow ALL IP"
    cidr_blocks = ["0.0.0.0/0"]   
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.environment}-http-https-sg"
    "Environment" = "${var.environment}"
  }
}
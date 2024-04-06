########################################
######    CREATE SSH KEYS
########################################
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./tls/private.pem"
  file_permission = "0600"
}

########################################
######    CREATE KEY PAIR
########################################
resource "aws_key_pair" "tf-ssh-key" {
  key_name   = "${var.environment}-ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# ########################################
# ######    CREATE NGINX EC2
# ########################################
resource "aws_instance" "public-ec2" {
  count = var.public_instance_count
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tf-ssh-key.key_name
  vpc_security_group_ids = [aws_security_group.sg.id, aws_security_group.sg-http-https.id, aws_security_group.sg-ssh.id]
  tags = {
    Name = "${var.environment}-vm-${count.index}"
  }
  subnet_id                   = aws_subnet.public-subnet[count.index].id
  user_data = <<-EOF
  #!/bin/bash
  apt update -y
  apt install -y nginx certbot python3-certbot-nginx 
  curl -fsSl https://get.docker.com | bash
  EOF
}


# ########################################
# ######    CREATE Jenkins EC2
# ########################################

resource "aws_instance" "jenkins-ec2" {
  count = 1
  ami                    = var.instance_ami
  instance_type          = var.jenkins_instance_type
  key_name               = aws_key_pair.tf-ssh-key.key_name
  vpc_security_group_ids = [aws_security_group.sg-jenkins.id, aws_security_group.sg-ssh.id]
  tags = {
    Name = "${var.environment}-vm-jenkins"
  }
  subnet_id                   = aws_subnet.public-subnet[count.index].id
  
  user_data = <<-EOF
  #!/bin/bash
  apt update -y
  apt install -y fontconfig openjdk-17-jre

  wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  apt-get update -y
  apt-get install -y jenkins
  curl -fsSl https://get.docker.com | bash
  usermod -aG docker jenkins
  systemctl restart docker
  
  EOF
}

# ########################################
# ######    CREATE Private EC2
# ########################################
resource "aws_instance" "private-ec2" {
  count = var.private_instance_count
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tf-ssh-key.key_name
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  tags = {
    Name = "${var.environment}-private-vm-${count.index}"
    "Environment" = "${var.environment}"
  }
  subnet_id                   = aws_subnet.private-subnet[count.index].id
}
variable "region" {
    default = "us-east-1"
}
variable "environment" {
    default = "dev"
}
variable "vpc_cidr" {
    default = "18.0.0.0/16"
}

variable "public_subnet_cidr" {
    default = ["18.0.0.0/24","18.0.2.0/24"]   ##,"18.0.2.0/24"
}

variable "private_subnet_cidr" {
    default = ["18.0.10.0/24","18.0.11.0/24"]   ##,"18.0.11.0/24"
}

variable "security_group_open_port" {
    default = [22, 22]
}
variable "security_group_allow_ip" {
    default = ["180.0.0.0/32"]
}

variable "public_instance_count" {
    default = 1
}
variable "private_instance_count" {
    default = 0
}
variable "instance_type" {
    default = "t2.micro"
}
variable "jenkins_instance_type"{
    default = "t2.medium"
}
variable "instance_ami" {
    # default = "ami-026b57f3c383c2eec" ## amazon linux
    default = "ami-0c1704bac156af62c"   ## Ubuntu
}
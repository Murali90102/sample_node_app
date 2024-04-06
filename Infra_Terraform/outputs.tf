output "local_workstation_ip" {
  value = local.workstation_external_ip
}
output "ec2_public_ip" {
  value = aws_instance.public-ec2[*].public_ip
}
output "private-ec2-ip" {
    value = aws_instance.private-ec2[*].private_ip 
}
output "Jenkins-IP" {
  value = aws_instance.jenkins-ec2[0].public_ip
}
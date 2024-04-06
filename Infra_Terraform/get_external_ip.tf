data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  workstation_external_ip = "${chomp(data.http.workstation-external-ip.body)}/32"
}
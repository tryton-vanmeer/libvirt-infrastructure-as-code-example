output "ip" {
  value = libvirt_domain.nginx.network_interface[0].addresses[0]
}

output "url" {
  value = "http://${var.hostname}.terraform.vm"
}

output "ssh" {
  value = "${var.ssh_username}@${var.hostname}.terraform.vm"
}
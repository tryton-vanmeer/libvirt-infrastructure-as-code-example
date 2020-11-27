variable "libvirt_disk_path" {
  description = "Path to create libvirt pool at."
  default = "/tmp/terraform-libvirt-pool"
}

variable "hostname" {
  description = "Hostname for the VM."
  default = "nginx"
}

variable "ssh_username" {
  description = "Name of user for SSH."
  default = "fedora"
}

variable "ssh_private_key" {
  description = "Location of SSH private key"
  default = "~/.ssh/id_rsa"
}

variable "ssh_public_key" {
  description = "Location of SSH public key."
  default = "~/.ssh/id_rsa.pub"
}
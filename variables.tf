variable "libvirt_disk_path" {
  description = "Path to create libvirt pool at."
  default = "/tmp/terraform-libvirt-pool"
}

variable "fedora_cloud_img_url" {
  description = "URL for Fedora image."
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/33/Cloud/x86_64/images/Fedora-Cloud-Base-33-1.2.x86_64.qcow2"
}

variable "vm_hostname" {
  description = "Hostname for the VM."
  default = "nginx"
}

variable "ssh_username" {
  description = "SSH user to use"
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
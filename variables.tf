variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default = "/tmp/terraform-libvirt-pool"
}

variable "fedora_cloud_img_url" {
  description = "fedora cloud image"
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/33/Cloud/x86_64/images/Fedora-Cloud-Base-33-1.2.x86_64.qcow2"
}

variable "vm_hostname" {
  description = "vm hostname"
  default = "nginx"
}

variable "ssh_username" {
  description = "the ssh user to use"
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
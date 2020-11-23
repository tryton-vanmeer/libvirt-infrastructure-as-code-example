variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default = "/tmp/terraform-libvirt-pool"
}

variable "linux_cloud_img_url" {
  description = "linux cloud image"
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/33/Cloud/x86_64/images/Fedora-Cloud-Base-33-1.2.x86_64.qcow2"
}

variable "vm_hostname" {
  description = "vm hostname"
  default = "terraform-libvirt-ansible"
}

variable "ssh_username" {
  description = "the ssh user to use"
  default = "root"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default = "~/.ssh/id_rsa"
}
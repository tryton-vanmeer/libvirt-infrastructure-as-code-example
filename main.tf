provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "terraform" {
  name = "terraform"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "fedora-qcow2" {
  name = "fedora-qcow2"
  pool = libvirt_pool.terraform.name
  source = var.fedora_cloud_img_url
  format = "qcow2"
}

resource "libvirt_domain" "domain-fedora" {
  name = var.vm_hostname
  memory = "512"
  vcpu = 1

  network_interface {
    network_name = "default"
    wait_for_lease = true
    hostname = var.vm_hostname
  }

  disk {
    volume_id = libvirt_volume.fedora-qcow2.id
  }
}
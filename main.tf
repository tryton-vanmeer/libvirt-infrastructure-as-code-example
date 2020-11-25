provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "terraform" {
  name = "terraform"
  domain = "terraform.vm"
  mode = "nat"
  addresses = ["10.0.100.0/24"]
  dns {
    local_only = true
  }
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

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data = file("${path.module}/config/cloud_init.yaml")
  pool = libvirt_pool.terraform.name
}

resource "libvirt_domain" "domain-fedora" {
  name = var.vm_hostname
  memory = "1024"
  vcpu = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "terraform"
    wait_for_lease = true
    hostname = var.vm_hostname
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.fedora-qcow2.id
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "[terraform]" > terraform.ini
      echo "${libvirt_domain.domain-fedora.network_interface[0].addresses[0]}" >> terraform.ini
      echo "[terraform:vars]" >> terraform.ini
      echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'" >> terraform.ini
      ansible-playbook -u ${var.ssh_username} --private-key ${var.ssh_private_key} -vvv ansible/playbook.yaml
    EOT
  }
}
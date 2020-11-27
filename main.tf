terraform {
 required_version = ">= 0.13"
  backend "local" {
    path = ".terraform/state/terraform.tfstate"
  }

  # Refer to https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/docs/migration-13.md for more info.
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

# Connect to the libvirt instance. qemu+ssh://user@example/system could be used for a remote connection.
provider "libvirt" {
  uri = "qemu:///system"
}

# Create a virtual network for terraform.
# Using dnsmasq with `server=/terraform.vm/10.0.100.1` would allow reaching the VM at hostname.terraform.vm.
resource "libvirt_network" "terraform" {
  name = "terraform"
  domain = "terraform.vm"
  mode = "nat"
  addresses = ["10.0.100.0/24"]
  dns {
    local_only = true
  }
}

# Create a libvirt storage pool for terraform.
resource "libvirt_pool" "terraform" {
  name = "terraform"
  type = "dir"
  path = var.libvirt_disk_path
}

# Create a storage volume for the domain.
# This can be a local image or a remote image like the Fedora Cloud Base in this case.
resource "libvirt_volume" "nginx" {
  name = "nginx.qcow2"
  pool = libvirt_pool.terraform.name
  source = "https://download.fedoraproject.org/pub/fedora/linux/releases/33/Cloud/x86_64/images/Fedora-Cloud-Base-33-1.2.x86_64.qcow2"
  format = "qcow2"
}

# Template out the userdata.yaml file for cloud-init.
# Passes in the content of the SSH key set in var.ssh_public_key.
data "template_file" "userdata" {
  template = file("${path.module}/templates/userdata.yaml")

  vars = {
    ssh_public_key = file(var.ssh_public_key)
  }
}

# Template out the metadata.yaml file for cloud-init.
data "template_file" "metadata" {
  template = file("${path.module}/templates/metadata.yaml")

  vars = {
    hostname = var.hostname
  }
}

# Create the cloud-init disk.
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data = data.template_file.userdata.rendered
  meta_data = data.template_file.metadata.rendered
  pool = libvirt_pool.terraform.name
}

# Create the domain; i.e the VM.
resource "libvirt_domain" "nginx" {
  name = var.hostname
  memory = "1024"
  vcpu = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "terraform"
    wait_for_lease = true
    hostname = var.hostname
  }

  # Add consoles that cloun-init expects.
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
    volume_id = libvirt_volume.nginx.id
  }

  # Provision the VM with Ansible.
  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.ssh_username} -i '${self.network_interface[0].addresses[0]},' --private-key ${var.ssh_private_key} provision.yaml"
  }
}
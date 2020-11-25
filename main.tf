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
# This can be a local image or a remote image, like the Fedora Cloud Base in this case.
resource "libvirt_volume" "nginx" {
  name = "nginx.qcow2"
  pool = libvirt_pool.terraform.name
  source = var.fedora_cloud_img_url
  format = "qcow2"
}

# Setup the cloud init disk.
# the pubkey is added to `ssh_authorized_keys`.
# For the purpose of this example, an SSH key-pair was created under config/ so cloud_init.yaml doesn't need edited.
# To SSH into the VM, specify the private key: `ssh -i config/fedora_rsa`.
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  user_data = file("${path.module}/config/cloud_init.yaml")
  pool = libvirt_pool.terraform.name
}

# Create the domain; i.e the VM.
resource "libvirt_domain" "nginx" {
  name = var.vm_hostname
  memory = "1024"
  vcpu = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "terraform"
    wait_for_lease = true
    hostname = var.vm_hostname
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

  # Write out an inventory file and run the playbook under ansible/.
  # Playbook just installs NGINX and enables the service.
  provisioner "local-exec" {
    command = <<EOT
      echo "[terraform]" > terraform.ini
      echo "${libvirt_domain.nginx.network_interface[0].addresses[0]}" >> terraform.ini
      echo "[terraform:vars]" >> terraform.ini
      echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'" >> terraform.ini
      ansible-playbook -u ${var.ssh_username} --private-key ${var.ssh_private_key} ansible/playbook.yaml
    EOT
  }
}
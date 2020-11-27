output "ip" {
  value = libvirt_domain.nginx.network_interface[0].addresses[0]
}

output "url" {
  value = "http://${var.hostname}.terraform.vm"
}

output "ssh" {
  value = "${var.ssh_username}@${var.hostname}.terraform.vm"
}

# Output an Ansible inventory, given the list of libvirt domains.
# This can be used to run post-provision playbooks.
resource "local_file" "AnsibleInventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
  {
    domains = [ libvirt_domain.nginx ]
  }
  )
  filename = "inventory"
}

# The provision playbook could be modified to be more basic.
# The nginx role could be applied after as post-provision.

# With the dnsmasq trick for local libvirt virtual networks, inventories
# could be written that don't need this generated one, since servers could be
# targeted at `hostname.terraform.vm`.
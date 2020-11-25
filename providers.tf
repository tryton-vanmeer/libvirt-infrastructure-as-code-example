# Refer to https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/docs/migration-13.md for more info.
terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}
# Libvirt Infrastructure as Code Example

Demo of deploying libvirt VMs using Terraform and Ansible.

Refer to comments in source files for further explanations.

## Requirements

+ [Terraform](https://www.terraform.io/downloads.html)
+ [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt#downloading)
+ libvirt

On Arch Linux, Terraform and the provider can be installed:

```
# pacman -S terraform terraform-provider-libvirt
```

Otherwise refer to Terraform and terraform-provider-libvirt documentation above.

## Running

### Terraform

Use Terraform to build the VMs.

```
$ terraform init
$ terraform plan
$ terraform appy
$ terraform destroy

```


### References
+ https://github.com/dmacvicar/terraform-provider-libvirt
+ https://blog.ruanbekker.com/blog/2020/10/08/using-the-libvirt-provisioner-with-terraform-for-kvm/
/* output metadata {
  value = { for key, value in data.template_file.metadata : key => value.rendered }
}

output userdata {
  value = { for key, value in data.template_file.userdata : key => value.rendered }
}

output "folder_name" {
  value = vsphere_folder.folder.path
} */

output "virtual_machine_ip" {
  value = { for vm_name, vm_config in var.vms : vm_name => vm_config.ip }
}

output "guest_ip_addresses" {
  value = { for vm_name in keys(var.vms) : vm_name => resource.vsphere_virtual_machine.this[vm_name].guest_ip_addresses }
}

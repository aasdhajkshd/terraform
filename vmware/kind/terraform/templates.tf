data "template_file" "metadata" {
  for_each = var.vms

  template = file("${path.module}/nodes/common/metadata.yml")
  vars = {
    dhcp        = "${each.value.dhcp}"
    ip          = "${each.value.ip}"
    netmask     = "${each.value.netmask}"
    hostname    = "${each.value.hostname}"
    instance_id = "${each.value.vmname}"
    gw          = "${each.value.gw}"
    dns         = jsonencode(var.vm_env.dns)
    domain      = "${var.vm_env.domain[0]}"
    search      = jsonencode(var.vm_env.domain)
  }
}

data "template_file" "userdata" {
  for_each = var.vms

  template = file("${path.module}/nodes/${each.value.vmname}/cloudinit.yml")
  vars = {
    username = "${each.value.username}"
    password = "${each.value.password}"
  }
}

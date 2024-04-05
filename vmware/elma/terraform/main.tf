provider "vsphere" {
  vsphere_server       = var.vsphere_env.server
  user                 = var.vsphere_env.user
  password             = var.vsphere_env.password
  allow_unverified_ssl = var.vsphere_env.insecure
}

locals {
  timestamp = replace(timestamp(), "/[-| |T|Z|:]/", "")
  dns       = var.vm_env.dns[0]
  domain    = var.vm_env.domain
}

resource "vsphere_virtual_machine" "this" {
  for_each = var.vms

  resource_pool_id = data.vsphere_resource_pool.this.id
  datastore_id     = data.vsphere_datastore.this.id
  host_system_id   = data.vsphere_host.this[each.key].id

  folder = vsphere_folder.folder.path

  name                   = "${each.value.vmname}-${local.timestamp}"
  num_cpus               = each.value.vcpu
  memory                 = each.value.vmem
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  cpu_share_level        = "high"

  guest_id        = data.vsphere_virtual_machine.template[each.key].guest_id
  scsi_type       = data.vsphere_virtual_machine.template[each.key].scsi_type
  firmware        = data.vsphere_virtual_machine.template[each.key].firmware
  force_power_off = true

  cdrom {
    client_device = true
  }

  wait_for_guest_net_timeout  = 2880
  wait_for_guest_net_routable = true

  network_interface {
    network_id   = data.vsphere_network.this.id
    adapter_type = data.vsphere_virtual_machine.template[each.key].network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = each.value.disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks.0.thin_provisioned
  }

  disk {
    label            = "disk1"
    size             = 16
    thin_provisioned = true
    unit_number      = 1
  }

  clone {
    # template_uuid = data.vsphere_content_library_item.this.id
    template_uuid = data.vsphere_virtual_machine.template[each.key].id
    timeout       = 720
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
    ]
  }

  extra_config = {
    "disk.EnableUUID"              = true
    "guestinfo.metadata"           = base64encode(data.template_file.metadata[each.key].rendered)
    "guestinfo.metadata.encoding"  = "base64"
    "guestinfo.userdata"           = base64encode(data.template_file.userdata[each.key].rendered)
    "guestinfo.userdata.encoding"  = "base64"
    "extra_config_reboot_required" = true
  }

  vapp {
    properties = {
      "user-data" = base64encode(templatefile("${path.module}/nodes/${each.value.vmname}/cloudinit.yml", {
        username = "${each.value.username}"
        password = "${each.value.password}"
      }))
      "meta-data" = base64encode(data.template_file.metadata[each.key].rendered)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait",
    ]
    connection {
      host = each.value.ip
      # host        = self.network_interface[0].nat_ip_address
      type = "ssh"
      user = each.value.username
      # password = each.value.password
      agent       = false
      private_key = file("~/.ssh/id_rsa-appuser")
      timeout     = 360
    }
  }
}

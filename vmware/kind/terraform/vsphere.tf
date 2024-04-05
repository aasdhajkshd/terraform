locals {
  vsphere_content_library_ovf = var.vsphere_content_library_ovf[0]
}

data "vsphere_datacenter" "this" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "this" {
  name          = var.vsphere_datastore[0]
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "vsphere_folder" "folder" {
  path          = var.project_name
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_compute_cluster" "this" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_resource_pool" "this" {
  name          = format("%s%s", data.vsphere_compute_cluster.this.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_host" "this" {
  for_each = var.vms

  name          = var.vsphere_host["esxi-1rzn25j"]
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_content_library" "this" {
  name = var.vsphere_content_library
}

data "vsphere_content_library_item" "this" {
  name       = local.vsphere_content_library_ovf
  type       = "ovf"
  library_id = data.vsphere_content_library.this.id
}

data "vsphere_virtual_machine" "template" {
  for_each      = var.vms
  name          = each.value.template
  datacenter_id = data.vsphere_datacenter.this.id
}

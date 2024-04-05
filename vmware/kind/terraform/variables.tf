##################################################################################
# VARIABLES
##################################################################################

# Credentials

variable "vsphere_env" {
  type = object({
    server   = string
    user     = string
    password = string
    insecure = bool
  })
  default = {
    server   = "vcenter.vsphere.local"
    user     = "administrator@vsphere.local"
    password = ""
    insecure = true
  }
}

# vSphere Settings

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_folder" {
  type = string
}

variable "vsphere_network" {
  type = string
}

variable "vsphere_content_library" {
  type    = string
  default = "Default"
}

variable "vsphere_content_library_ovf" {
  type    = list(string)
  default = ["debian-11-bullseye-cloud-init", "debian-12-bookwork-cloud-init", ]
}

# Virtual Machine Settings defaults

variable "vm_firmware" {
  type    = list(string)
  default = ["bios", "efi"]
}

variable "vm_efi_secure_boot_enabled" {
  type    = bool
  default = false
}

variable "vm_env" {
  type = object({
    gw        = string
    dns       = list(string)
    domain    = list(string)
    cpus      = number
    vmem      = number
    disk_size = number
  })
  default = {
    gw        = "10.10.10.1"
    dns       = ["10.10.10.3", "8.8.8.8"]
    domain    = ["vsphere.local"]
    cpus      = 2
    vmem      = 4096
    disk_size = 20
  }
}

variable "vms" {
  type = map(object({
    vcpu      = number
    vmem      = number
    disk_size = number
    vmname    = string
    datastore = string
    template  = string
    dhcp      = bool
    ip        = string
    netmask   = string
    gw        = string
    hostname  = string
    username  = string
    password  = string
  }))
}

# Custom Settings

variable "vsphere_template" {
  description = "ESXi templates"
  type        = list(string)
  default     = ["_Debian-12"]
}

variable "vsphere_host" {
  description = "ESXi hosts"
  type        = map(any)
  default = {
    "esxi-1rzn25j"  = "10.10.10.201"
    "esxi-s4clj032" = "10.10.10.202"
    "esxi-s4clj015" = "10.10.10.203"
    "esxi-s4clj111" = "10.10.10.204"
  }
}

variable "vsphere_datastore" {
  description = "ESXi datastores"
  type        = list(string)
  default     = ["DS-1RZN25J-3", "DS-S4CLJ015-SSD", "DS-S4CLJ111-SSD", "DS-2S6146B738-1", "DS-2S6146B738-3"]
}

variable "instance_count" {
  description = "Number of instances of hosts"
  type        = map(any)
  default = {
    "kind" = 1
  }
}

variable "instance_tag" {
  type    = list(string)
  default = ["kind"]
}

variable "instance_resources" {
  description = "Instance resources"
  type        = map(any)
  default = {
    "cores"  = 2
    "memory" = 4
  }
}

variable "project_name" {
  description = "Project name used a first part of hostname"
  type        = string
  default     = "test"
}

variable "ipv4_address_network" {
  description = "Network and CIDR"
  type        = string
}

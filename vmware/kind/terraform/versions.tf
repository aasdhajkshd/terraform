##################################################################################
# VERSIONS
##################################################################################

terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.5.1"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.1.2"
    }
  }
  required_version = ">= 1.5.7"
}

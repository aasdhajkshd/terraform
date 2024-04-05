provider "remote" {
  max_sessions = 10
}

// we need to allow cloud-init finish reboot
resource "time_sleep" "wait_for_reboot" {
  depends_on = [vsphere_virtual_machine.this]

  create_duration = "1m"
}

resource "null_resource" "install-kind" {
  for_each = var.vms

  triggers = {
    is_kind = contains(keys(each.value), "kind")
  }

  depends_on = [time_sleep.wait_for_reboot]

  provisioner "remote-exec" {
    inline = [
      "~/install.sh",
    ]
    connection {
      host        = each.value.ip
      type        = "ssh"
      user        = each.value.username
      agent       = false
      private_key = file("~/.ssh/id_rsa-appuser")
      timeout     = 3600
    }
  }

}

data "remote_file" "kubeconfig" {
  for_each = var.vms

  depends_on = [null_resource.install-kind]

  path = "/home/${each.value.username}/.kube/config"

  conn {
    host        = each.value.ip
    user        = each.value.username
    private_key = file("~/.ssh/id_rsa-appuser")
  }
}

resource "null_resource" "kubeconfig" {
  for_each = var.vms

  depends_on = [data.remote_file.kubeconfig]

  provisioner "local-exec" {
    command = <<-EOT
      /usr/bin/mkdir -p /tmp/${each.key}/.kube
      echo "${data.remote_file.kubeconfig[each.key].content}" > "/tmp/${each.key}/.kube/config"
    EOT
  }
}

output "kubeconfig" {
  value = { for vm_name in keys(var.vms) : vm_name => data.remote_file.kubeconfig[vm_name].content }
}

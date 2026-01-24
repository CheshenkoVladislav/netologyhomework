locals {
  vm_common = "netology-develop-platform"
  vm_web_name = "${local.vm_common}-${var.vm_web_name}"
  vm_db_name  = "${local.vm_common}-${var.vm_db_name}"

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}

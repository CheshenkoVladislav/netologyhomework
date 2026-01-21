locals {
  vm_web_name = "${var.vm_web_name}"
  vm_db_name  = "${var.vm_db_name}"

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}


variable "each_vm" {
  type = list(object({
    vm_name       = string,
    cpu           = number,
    ram           = number,
    disk_volume   = number,
    disk_type     = string,
    core_fraction = number
  }))
  default = [
    {
      vm_name       = "main"
      cpu           = 2
      ram           = 4
      disk_volume   = 15
      disk_type     = "network-hdd"
      core_fraction = 20
    },
    {
      vm_name       = "replica"
      cpu           = 4
      ram           = 8
      disk_volume   = 12
      disk_type     = "network-hdd"
      core_fraction = 20
    }
  ]
}

data "yandex_compute_image" "db-image" {
  family = var.compute_image_name
}

resource "yandex_compute_instance" "db" {
  allow_stopping_for_update = true
  for_each                  = { for vm in var.each_vm : vm.vm_name => vm }
  name                      = each.value.vm_name
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.db-image.image_id
      type     = each.value.disk_type
      size     = each.value.disk_volume
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = file("${path.module}/${var.cloud_config_file_name}")
  }
}

output "external_ip_db" {
  value = [for k, v in yandex_compute_instance.db : "${k} : ${v.network_interface[0].nat_ip_address}"]
}

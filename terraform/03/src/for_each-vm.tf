
variable "each_vm" {
  type = list(object({
    vm_name     = string,
    cpu         = number,
    ram         = number,
    disk_volume = number
  }))
  default = [
    {
      vm_name     = "main"
      cpu         = 2
      ram         = 4
      disk_volume = 15
    },
    {
      vm_name     = "replica"
      cpu         = 4
      ram         = 8
      disk_volume = 12
    }
  ]
}

data "yandex_compute_image" "db-image" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "db" {
  allow_stopping_for_update = true
  for_each                  = { for vm in var.each_vm : vm.vm_name => vm }
  name                      = each.value.vm_name
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.db-image.image_id
      type     = "network-hdd"
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
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = file("${path.module}/cloud_config.yaml")
  }
}

output "external_ip_db" {
  value = [for k,v in yandex_compute_instance.db : "${k} : ${v.network_interface[0].nat_ip_address}"]
}
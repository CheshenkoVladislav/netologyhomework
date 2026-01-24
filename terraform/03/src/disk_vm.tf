variable "disk_config" {
  type = object({
    name  = string,
    type  = string,
    size  = number,
    zone  = string,
    label = string
  })
  default = {
    name  = "disk-"
    type  = "network-hdd"
    size  = "8"
    zone  = "ru-central1-a"
    label = "test"
  }
}

variable "storage_instance_config" {
  type = object({
    cores         = number,
    memory        = number,
    core_fraction = number,
    nat           = bool,
    preemptible   = bool
  })
  default = {
    cores         = 2,
    memory        = 2,
    core_fraction = 20,
    nat           = true,
    preemptible   = true
  }
}

data "yandex_compute_image" "storage_image" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "hdd1tb" {
  count    = 2
  name     = "${var.disk_config.name}-${count.index}"
  type     = var.disk_config.type
  size     = var.disk_config.size
  zone     = var.disk_config.zone
  image_id = data.yandex_compute_image.storage_image.image_id

  labels = {
    environment = var.disk_config.label
  }
}

resource "yandex_compute_instance" "storage" {
  count = 1
  name  = "storage-${count.index + 1}"
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.storage_image.image_id
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = var.storage_instance_config.nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  resources {
    cores         = var.storage_instance_config.cores
    memory        = var.storage_instance_config.memory
    core_fraction = var.storage_instance_config.core_fraction
  }
  scheduling_policy {
    preemptible = var.storage_instance_config.preemptible
  }

  dynamic "secondary_disk" {
    for_each = toset(yandex_compute_disk.hdd1tb[*].id)
    content {
      disk_id = secondary_disk.value
    }
  }

  metadata = {
    user-data = file("${path.module}/cloud_config.yaml")
  }
}

output "external_ip_storage" {
  value = yandex_compute_instance.storage[*].network_interface[0].nat_ip_address
}

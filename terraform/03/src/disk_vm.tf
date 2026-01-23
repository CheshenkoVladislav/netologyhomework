data "yandex_compute_image" "storage_image" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "hdd1tb" {
  count    = 2
  name     = "disk-${count.index}"
  type     = "network-hdd"
  size     = 8
  zone     = "ru-central1-a"
  image_id = data.yandex_compute_image.storage_image.image_id

  labels = {
    environment = "test"
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
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }

  dynamic secondary_disk {
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

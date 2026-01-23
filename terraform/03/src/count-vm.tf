data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "web" {
  count = 2
  name = "web-${count.index + 1}"
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.image_id
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
  metadata = {
    user-data = file("${path.module}/cloud_config.yaml")
  }
}

output "external_ip_web" {
  value = yandex_compute_instance.web[*].network_interface.0.nat_ip_address
}

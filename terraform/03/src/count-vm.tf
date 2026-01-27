data "yandex_compute_image" "ubuntu_image" {
  family = var.compute_image_name
}

variable "instance_resources" {
  type = object({
    cores         = number,
    memory        = number,
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

resource "yandex_compute_instance" "web" {
  count = 2
  name = "${var.web_prefix}-${count.index + 1}"
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
    cores         = var.instance_resources.cores
    memory        = var.instance_resources.memory
    core_fraction = var.instance_resources.core_fraction
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = file("${path.module}/${var.cloud_config_file_name}")
  }
}

output "external_ip_web" {
  value = yandex_compute_instance.web[*].network_interface.0.nat_ip_address
}

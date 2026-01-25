terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.13.0"
}

resource "yandex_vpc_network" "custom_net" {
  name = var.net_name
}

resource "yandex_vpc_subnet" "custom_subnet" {
  name           = var.subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.custom_net.id
  v4_cidr_blocks = var.v4_cidr_blocks
}

output "out" {
  value = yandex_vpc_subnet.custom_subnet
}
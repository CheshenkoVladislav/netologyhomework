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
  for_each = { for index, subnet in var.subnets : index => subnet }
  name           = "${var.net_name}-Subnet-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.custom_net.id
  v4_cidr_blocks = [each.value.cidr]
}

output "out" {
  value = yandex_vpc_subnet.custom_subnet
}
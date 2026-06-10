terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  token = var.token
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_route_table" "route_table" {
  name       = "route-table"
  network_id = yandex_vpc_network.network.id
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat-instance.network_interface[0].ip_address
  }
}

resource "yandex_compute_instance" "nat-instance" {
  name = "nat-instance"
  platform_id = "standard-v3"
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat = true
  }
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = file("${path.module}/cloud_config.yaml")
  }
}

resource "yandex_compute_instance" "vm1" {
  name = "vm-1"
  platform_id = "standard-v3"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image_id = "fd84aqtri79if91dbg21" //ubuntu 24.04
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = file("${path.module}/cloud_config.yaml")
  }
}
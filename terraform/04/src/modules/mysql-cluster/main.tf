terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.13.0"
}

resource "yandex_mdb_mysql_cluster" "my_cluster" {
  name        = var.name
  environment = "PRESTABLE"
  network_id  = var.net_id
  version     = "8.0"

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-hdd"
    disk_size          = 11
  }

  mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = 10
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = true
  }


  dynamic "host" {
    for_each = yandex_vpc_subnet.cluster_subnet
    content {
      zone      = host.value.zone
      subnet_id = host.value.id
    }
  }

  depends_on = [ yandex_vpc_subnet.cluster_subnet ]
}

resource "yandex_vpc_subnet" "cluster_subnet" {
  count          = var.HA ? 2 : 1
  zone           = "ru-central1-a"
  network_id     = var.net_id
  v4_cidr_blocks = ["10.0.${count.index + 1}.0/24"]
}

output "out" {
  value = yandex_mdb_mysql_cluster.my_cluster.id
}
variable "replica_hosts" {
  type = list(object({
    zone : string,
    subnet_id : string
  }))
  default = []
}

locals {
  replica_hosts_filled = [
    {
      id : yandex_vpc_subnet.private.id,
      zone : yandex_vpc_subnet.private.zone
    },
    {
      id : yandex_vpc_subnet.private-central-b.id,
      zone : yandex_vpc_subnet.private-central-b.zone
    }
  ]
}

resource "yandex_mdb_mysql_cluster" "my_cluster" {
  name                = "my_cluster"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.network.id
  version             = "8.0"
  deletion_protection = false

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  maintenance_window {
    type    = "WEEKLY"
    day     = "SAT"
    hour    = 24
  }

  dynamic "host" {
    for_each = local.replica_hosts_filled
    content {
      zone      = host.value.zone
      subnet_id = host.value.id
    }
  }
}

resource "yandex_mdb_mysql_database" "my_db" {
  cluster_id = yandex_mdb_mysql_cluster.my_cluster.id
  name       = "my_db"
}

resource "yandex_mdb_mysql_user" "my_user" {
  cluster_id = yandex_mdb_mysql_cluster.my_cluster.id
  name       = "john"
  password   = "password"

  permission {
    database_name = yandex_mdb_mysql_database.my_db.name
    roles         = ["ALL"]
  }

  permission {
    database_name = yandex_mdb_mysql_database.my_db.name
    roles         = ["ALL", "INSERT"]
  }

  global_permissions = ["PROCESS"]

  authentication_plugin = "SHA256_PASSWORD"
}

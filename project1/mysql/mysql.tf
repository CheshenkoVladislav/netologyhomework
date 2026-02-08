terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.181.0"
    }
  }
  required_version = "~>1.13.0"
}

variable "zone" {
  type = string
}

variable "network_config" {
  type = object({
    network_id               = string
    permitted_v4_cidr_blocks = list(string)
  })
}

resource "yandex_vpc_security_group" "netologia_project_1_sg_db" {
  name        = "database_sg"
  description = "Project 1 Security group"
  network_id  = var.network_config.network_id

  ingress {
    description    = "HTTPS rule"
    v4_cidr_blocks = var.network_config.permitted_v4_cidr_blocks
    port           = 3306
    protocol       = "TCP"
  }

  egress {
    description    = "HTTPS rule"
    v4_cidr_blocks = var.network_config.permitted_v4_cidr_blocks
    protocol       = "TCP"
  }
}

resource "yandex_vpc_subnet" "netologia_project_1_subnet_db" {
  v4_cidr_blocks = ["10.0.2.0/24"]
  network_id     = var.network_config.network_id
  zone           = var.zone
}

variable "mysql_db_name" {
  type = string
}

resource "yandex_mdb_mysql_database" "netologia_project_1_mysql_db" {
  cluster_id = yandex_mdb_mysql_cluster.netologia_project_1_mysql_cluster.id
  name       = var.mysql_db_name
}

resource "yandex_mdb_mysql_cluster" "netologia_project_1_mysql_cluster" {
  name               = "netologia_project_1_mysql_cluster"
  environment        = "PRESTABLE"
  network_id         = var.network_config.network_id
  version            = "8.0"
  security_group_ids = [yandex_vpc_security_group.netologia_project_1_sg_db.id]

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  mysql_config = {
    max_connections               = 100
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = true
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.netologia_project_1_subnet_db.id
  }
}

variable "db_user" {
  type = object({
    name     = string
    password = string
  })
}

resource "yandex_mdb_mysql_user" "user1" {
  cluster_id = yandex_mdb_mysql_cluster.netologia_project_1_mysql_cluster.id
  name       = var.db_user.name
  password   = var.db_user.password

  permission {
    database_name = yandex_mdb_mysql_database.netologia_project_1_mysql_db.name
    roles         = ["SELECT", "INSERT", "UPDATE", "CREATE"]
  }
}

output "out" {
  value = {
    cluster_fqdn = yandex_mdb_mysql_cluster.netologia_project_1_mysql_cluster.host[0].fqdn
  }
}

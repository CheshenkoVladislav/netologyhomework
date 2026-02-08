resource "yandex_vpc_security_group" "netologia_project_1_sg_db" {
  name        = "database_sg"
  description = "Project 1 Security group"
  network_id  = yandex_vpc_network.netologia_project_1_network.id

  ingress {
    description    = "HTTPS rule"
    v4_cidr_blocks = yandex_vpc_subnet.netologia_project_1_subnet.v4_cidr_blocks
    port           = 3306
    protocol       = "TCP"
  }

  egress {
    description    = "HTTPS rule"
    v4_cidr_blocks = yandex_vpc_subnet.netologia_project_1_subnet.v4_cidr_blocks
    protocol       = "TCP"
  }

  labels = {
    tag = "${local.tag}_db_sg"
  }
}

resource "yandex_vpc_subnet" "netologia_project_1_subnet_db" {
  v4_cidr_blocks = ["10.0.2.0/24"]
  network_id     = yandex_vpc_network.netologia_project_1_network.id
  zone           = var.zone
}

resource "yandex_mdb_mysql_database" "netologia_project_1_mysql_db" {
  cluster_id = yandex_mdb_mysql_cluster.netologia_project_1_mysql_cluster.id
  name       = "netologia_project_1_mysql_db"
}

resource "yandex_mdb_mysql_cluster" "netologia_project_1_mysql_cluster" {
  name               = "netologia_project_1_mysql_cluster"
  environment        = "PRESTABLE"
  network_id         = yandex_vpc_network.netologia_project_1_network.id
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
    sql_mode                    = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.netologia_project_1_subnet_db.id
  }
}

variable "mysql_pass_lockbox_secret_id" {
  type = string
}

data "yandex_lockbox_secret_version" "mysql_logopass" {
  secret_id = var.mysql_pass_lockbox_secret_id
}

resource "yandex_mdb_mysql_user" "user1" {
  cluster_id = yandex_mdb_mysql_cluster.netologia_project_1_mysql_cluster.id
  name       = data.yandex_lockbox_secret_version.mysql_logopass.entries[0].key
  password   = data.yandex_lockbox_secret_version.mysql_logopass.entries[0].text_value

  permission {
    database_name = yandex_mdb_mysql_database.netologia_project_1_mysql_db.name
    roles         = ["SELECT", "INSERT", "UPDATE", "CREATE"]
  }
}

output "cluster_info" {
  value = yandex_mdb_mysql_cluster.netologia_project_1_mysql_cluster.host[0].fqdn
}

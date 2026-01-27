terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.13.0"
}

resource "yandex_mdb_mysql_database" "my_db" {
  cluster_id = var.cluster_id
  name       = var.db_name
}

resource "random_password" "password" {
  length           = 16
  special          = true
}

resource "yandex_mdb_mysql_user" "my_user" {
  cluster_id = var.cluster_id
  name       = var.user_name
  password   = random_password.password.result

  permission {
    database_name = yandex_mdb_mysql_database.my_db.name
    roles         = ["ALL"]
  }

  connection_limits {
    max_questions_per_hour   = 10
    max_updates_per_hour     = 20
    max_connections_per_hour = 30
    max_user_connections     = 40
  }

  global_permissions = ["PROCESS"]

  authentication_plugin = "SHA256_PASSWORD"
}

output "out" {
  value = {
    db   = yandex_mdb_mysql_database.my_db.name
    user = {
        name = yandex_mdb_mysql_user.my_user.name
        password = yandex_mdb_mysql_user.my_user.password
    }
  }
}
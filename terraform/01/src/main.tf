terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
  required_version = "~>1.13.0" /*Многострочный комментарий.
 Требуемая версия terraform */
}
provider "docker" {
  host = "ssh://admin2@130.193.45.223"
}

#однострочный комментарий

resource "random_password" "random_string" {
  count = 2
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource docker_image mysql {
  name = "mysql:8.0"
  keep_locally = true
}

resource docker_container database {
  image = docker_image.mysql.image_id
  name  = "hello_world_mysql"

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.random_string[0].result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.random_string[1].result}"
  ]
}
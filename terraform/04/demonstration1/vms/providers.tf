terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.180.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0" # Укажите актуальную версию
    }
  }
  required_version = "~>1.13.0"

  backend "s3" {
    bucket = "b1gv6lhe0hp2uq4030l5-bucket"
    key    = "terraform.tfstate"
    region = "ru-central1"

    # Встроенный механизм блокировок (Terraform >= 1.6)
    # Не требует отдельной базы данных!
    use_lockfile = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

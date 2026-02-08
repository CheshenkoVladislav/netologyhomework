terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.181.0"
    }
  }
  backend "s3" {
    bucket = "netologia-vcheshenko-s3"
    key    = "terraform.tfstate"
    region = "ru-central1-a"


    use_lockfile = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

  required_version = "~>1.13.0"
}

variable "token" {
  type      = string
  sensitive = true
}

variable "folder_id" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "zone" {
  type = string
}

provider "yandex" {
  token     = var.token
  folder_id = var.folder_id
  cloud_id  = var.cloud_id
  zone      = var.zone
}

variable "s3_service_account_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

module "s3" {
  source                = "./s3"
  bucket_name           = var.bucket_name
  s3_service_account_id = var.s3_service_account_id
  s3_folder_id          = var.folder_id
  s3_zone               = var.zone
}
# secret = [
#   { <login> = <password> }
#   { <root_login> = <root_password> }
# ]
variable "mysql_pass_lockbox_secret_id" {
  type = string
}

data "yandex_lockbox_secret_version" "mysql_logopass" {
  secret_id = var.mysql_pass_lockbox_secret_id
}

variable "mysql_db_name" {
  type = string
}

module "mysql" {
  source        = "./mysql"
  zone          = var.zone
  mysql_db_name = var.mysql_db_name
  network_config = {
    network_id               = yandex_vpc_network.netologia_project_1_network.id
    permitted_v4_cidr_blocks = yandex_vpc_subnet.netologia_project_1_subnet.v4_cidr_blocks
  }
  db_user = {
    name     = data.yandex_lockbox_secret_version.mysql_logopass.entries[0].key
    password = data.yandex_lockbox_secret_version.mysql_logopass.entries[0].text_value
  }
}

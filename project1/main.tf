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

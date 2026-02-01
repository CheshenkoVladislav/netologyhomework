terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = "~>1.13.0"
}

provider "yandex" {
  token                    = var.yc_token
  cloud_id                 = var.yc_cloud_id
  folder_id                = var.yc_folder_id
  zone                     = var.yc_zone
}

variable "yc_folder_id" {
  type        = string
  description = "folder_id для привязки сервисного аккаунта"
}

variable "yc_zone" {
  type = string
  default = "ru-central1-a"
}

variable "yc_cloud_id" {
  type = string
}

variable "yc_token" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

resource "yandex_iam_service_account" "sa" {
  name        = var.service_account_name
  description = "Сервисный аккаунт для Terraform"
}

// Назначение роли сервисному аккаунту (опционально, например, editor)
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}


resource "yandex_storage_bucket" "iam-bucket" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  max_size = 1048576

  versioning {
    enabled = true
  }
}


output "out" {
  value = {
    bucket_name = yandex_storage_bucket.iam-bucket.bucket_domain_name
    keys = {
      access_key_id = nonsensitive(yandex_iam_service_account_static_access_key.sa-static-key.access_key)
      secret_key    = nonsensitive(yandex_iam_service_account_static_access_key.sa-static-key.secret_key)
    }
    backend_config_example = <<EOT
    backend "s3" {
        bucket  = "${var.bucket_name}"
        key     = "terraform.tfstate"
        region  = "${var.yc_zone}"
    
   
        use_lockfile = true
    
        endpoints = {
            s3 = "https://storage.yandexcloud.net"
        }
    
        skip_region_validation      = true
        skip_credentials_validation = true
        skip_requesting_account_id  = true
        skip_s3_checksum            = true
    }
    EOT
  }
}

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.181.0"
    }
  }
  required_version = "~>1.13.0"
}

variable "s3_service_account_id" {
  type = string
}

variable "s3_folder_id" {
  type = string
}

variable "s3_zone" {
  type = string
}

variable "bucket_name" {
  type = string
}

data "yandex_iam_service_account" "s3_maintainer" {
  service_account_id = var.s3_service_account_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.s3_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${data.yandex_iam_service_account.s3_maintainer.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = data.yandex_iam_service_account.s3_maintainer.id
  description        = "static access key for object storage"
}


resource "yandex_storage_bucket" "iam-bucket" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  max_size = 1048576000

  versioning {
    enabled = true
  }
}


output "out" {
  value = {
    bucket_name = yandex_storage_bucket.iam-bucket.bucket_domain_name
    keys = {
      access_key_id = sensitive(yandex_iam_service_account_static_access_key.sa-static-key.access_key)
      secret_key    = sensitive(yandex_iam_service_account_static_access_key.sa-static-key.secret_key)
    }
    backend_config_example = <<EOT
    backend "s3" {
        bucket  = "${var.bucket_name}"
        key     = "terraform.tfstate"
        region  = "${var.s3_zone}"
    
   
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

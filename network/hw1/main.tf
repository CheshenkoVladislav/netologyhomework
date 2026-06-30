terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone      = "ru-central1-a"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  token     = var.token
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  # route_table_id = yandex_vpc_route_table.route_table.id
}


resource "yandex_vpc_subnet" "private-central-b" {
  name           = "private-central-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.21.0/24"]
  # route_table_id = yandex_vpc_route_table.route_table.id
}

# resource "yandex_vpc_route_table" "route_table" {
#   name       = "route-table"
#   network_id = yandex_vpc_network.network.id

#   static_route {
#     destination_prefix = "0.0.0.0/0"
#     next_hop_address = yandex_compute_instance.nat-instance.network_interface[0].ip_address
#   }
# }

resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = file("${path.module}/cloud_config.yaml")
  }
}

# resource "yandex_compute_instance" "vm1" {
#   name                      = "vm-1"
#   platform_id               = "standard-v3"
#   allow_stopping_for_update = true
#   boot_disk {
#     initialize_params {
#       image_id = "fd827b91d99psvq5fjit" //ubuntu 24.04
#     }
#   }
#   network_interface {
#     subnet_id = yandex_vpc_subnet.public.id
#   }
#   resources {
#     cores         = 2
#     memory        = 2
#     core_fraction = 20
#   }
#   scheduling_policy {
#     preemptible = true
#   }
#   metadata = {
#     user-data = file("${path.module}/cloud_config.yaml")
#   }
# }


# resource "yandex_storage_bucket" "iam-bucket" {
#   bucket    = "netology-cheshenko"
#   folder_id = var.folder_id

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         kms_master_key_id = yandex_kms_symmetric_key.my_key.id
#         sse_algorithm = "aws:kms"
#       }
#     }
#   }
# }

# resource "yandex_storage_object" "my_file" {
#   bucket       = yandex_storage_bucket.iam-bucket.id
#   key          = "/image_in_bucket.png"
#   source       = "./image_in_bucket.png"
#   acl          = "public-read"
#   content_type = "image/png"
# }

# resource "yandex_iam_service_account" "netology-service-account" {
#   name      = "netology-service"
#   folder_id = var.folder_id
# }

# resource "yandex_iam_service_account_iam_binding" "sa-binding" {
#   service_account_id = yandex_iam_service_account.netology-service-account.id
#   role               = "editor"

#   members = [
#     "userAccount:ajecb53h59k74p604p0o"
#   ]
# }

# resource "yandex_resourcemanager_folder_iam_binding" "folder-editor-binding" {
#   folder_id = var.folder_id
#   role      = "editor"

#   members = [
#     "serviceAccount:${yandex_iam_service_account.netology-service-account.id}",
#   ]
# }

# Instance Group
# resource "yandex_compute_instance_group" "web" {
#   name                = "test-ig"
#   folder_id           = var.folder_id
#   service_account_id  = yandex_iam_service_account.netology-service-account.id
#   deletion_protection = false
#   instance_template {
#     platform_id = "standard-v1"
#     resources {
#       memory        = 2
#       cores         = 2
#       core_fraction = 20
#     }
#     boot_disk {
#       mode = "READ_WRITE"
#       initialize_params {
#         image_id = "fd827b91d99psvq5fjit"
#         size     = 4
#       }
#     }

#     scheduling_policy {
#       preemptible = true
#     }
#     network_interface {
#       network_id = yandex_vpc_network.network.id
#       subnet_ids = ["${yandex_vpc_subnet.public.id}"]
#     }
#     labels = {
#       type = "web-public-vm"
#     }
#     metadata = {
#       user-data = templatefile("${path.module}/cloud_config.yaml.tftpl", {
#         index = indent(6, file("${path.module}/index.html"))
#       })
#     }
#   }

#   health_check {
#     healthy_threshold   = 2
#     interval            = 60
#     timeout             = 10
#     unhealthy_threshold = 3
#     http_options {
#       path = "/"
#       port = 80
#     }
#   }

#   scale_policy {
#     fixed_scale {
#       size = 2
#     }
#   }

#   allocation_policy {
#     zones = ["ru-central1-a"]
#   }

#   deploy_policy {
#     max_unavailable = 1
#     max_creating    = 2
#     max_expansion   = 2
#     max_deleting    = 2
#   }
# }

# resource "yandex_lb_target_group" "web_tg" {
#   name      = "web-target-group"
#   folder_id = var.folder_id

#   dynamic "target" {
#     for_each = yandex_compute_instance_group.web.instances
#     content {
#       subnet_id = target.value.network_interface[0].subnet_id
#       address   = target.value.network_interface[0].ip_address
#     }
#   }
# }

# resource "yandex_lb_network_load_balancer" "web_balancer" {
#   name = "web-balancer"
#   listener {
#     name = "http-listener"
#     port = 80
#   }
#   attached_target_group {
#     target_group_id = yandex_lb_target_group.web_tg.id
#     healthcheck {
#       name = "web-check"
#       http_options {
#         port = 80
#         path = "/"
#       }
#     }
#   }
# }

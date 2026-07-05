resource "yandex_kubernetes_cluster" "regional_cluster" {
  name        = "name"
  description = "description"

  network_id = yandex_vpc_network.network.id

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public.zone
        subnet_id = yandex_vpc_subnet.public.id
      }

      location {
        zone      = yandex_vpc_subnet.public-central1-b.zone
        subnet_id = yandex_vpc_subnet.public-central1-b.id
      }

      location {
        zone      = yandex_vpc_subnet.public-central1-d.zone
        subnet_id = yandex_vpc_subnet.public-central1-d.id
      }
    }

    version   = "1.33"
    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }
    }

    scale_policy {
      auto_scale {
        min_resource_preset_id = "s-c4-m16"
      }
    }
  }

  kms_provider {
    key_id = yandex_kms_symmetric_key.my_key.id
  } 

  service_account_id      = yandex_iam_service_account.netology-service-account.id
  node_service_account_id = yandex_iam_service_account.netology-service-account.id

  release_channel = "STABLE"

  workload_identity_federation {
    enabled = true
  }
}

resource "yandex_kubernetes_cluster_iam_binding" "editor" {
    cluster_id = yandex_kubernetes_cluster.regional_cluster.id
    role = "editor"
    members = [
        "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
    ]
}

//
// Create a new Managed Kubernetes Node Group.
//
resource "yandex_kubernetes_node_group" "node_group" {
  cluster_id  = yandex_kubernetes_cluster.regional_cluster.id
  name        = "node-group"
  description = "description"
  version     = "1.33"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 40
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public.zone
    }
  }

  scale_policy {
    auto_scale {
      initial = 3
      max = 6
      min = 3
    }
  }

  workload_identity_federation {
    enabled = true
  }
}
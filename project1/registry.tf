resource "yandex_container_registry" "netologia_project_1_container_registry" {
  name      = "netologia-project-1-container-registry"
  folder_id = var.folder_id

  labels = {
    tag = "${local.tag}_container_registry"
  }
}

output "registry_id" {
  value = yandex_container_registry.netologia_project_1_container_registry.id
}

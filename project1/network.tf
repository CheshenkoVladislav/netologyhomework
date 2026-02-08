resource "yandex_vpc_network" "netologia_project_1_network" {
  name = "netologia_project_1_network"
  labels = {
    tag = "${local.tag}_network"
  }
}
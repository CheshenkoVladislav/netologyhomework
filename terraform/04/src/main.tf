# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }
# resource "yandex_vpc_subnet" "develop" {
#   name           = var.vpc_name
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }

module "vpc_local" {
  net_name       = var.vpc_name
  subnet_name    = "${var.vpc_name}-subnet"
  source         = "./modules/vpc"
  zone           = var.default_zone
  v4_cidr_blocks = var.default_cidr
}

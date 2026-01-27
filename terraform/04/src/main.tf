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
  source         = "./modules/vpc"
}

module "mysql_cluster" {
  source    = "./modules/mysql-cluster"
  name      = "example"
  net_id    = module.vpc_local.out.net
  HA        = true

  depends_on = [ module.vpc_local ]
}

module "mysql_db" {
  source      = "./modules/mysql-database"
  cluster_id  = module.mysql_cluster.out
  db_name     = "test"
  user_name   = "app"  
}

module "s3_bucket" {
  source = "git::https://github.com/terraform-yc-modules/terraform-yc-s3.git?ref=1.0.4"
}

output "result" {
  value = {
    vpc           = module.vpc_local.out
    mysql_cluster = module.mysql_cluster.out
    mysql_db      = module.mysql_db.out
  }
  sensitive = true
}
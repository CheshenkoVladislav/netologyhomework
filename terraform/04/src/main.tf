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
  source = "git::https://github.com/terraform-yc-modules/terraform-yc-s3.git?ref=791f53698dd13ee97bc1cbe51b765f2d10f1d273"
  bucket_name = "b1gv6lhe0hp2uq4030l5-bucket"
  max_size = 1000000000
}

output "s3_output" {
  value = module.s3_bucket.bucket_name
}

output "result" {
  value = {
    vpc           = module.vpc_local.out
    mysql_cluster = module.mysql_cluster.out
    mysql_db      = module.mysql_db.out
  }
  sensitive = true
}
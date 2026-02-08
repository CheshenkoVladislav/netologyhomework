data "cloudinit_config" "web_init" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/web-init.yml.tpl", {
      token = var.token
    })
  }
}

resource "local_file" "compose_init" {
  depends_on = [module.mysql]
  filename   = "${path.module}/webserver_src/compose.yaml"
  content = templatefile("${path.module}/templates/compose_yc.yaml.tpl", {
    db_host = module.mysql.out.cluster_fqdn
  })
}

resource "local_file" "env" {
  depends_on = [module.mysql]
  filename   = "${path.module}/webserver_src/.env"
  content = templatefile("${path.module}/templates/env.tpl", {
    mysql_db_name       = var.mysql_db_name
    mysql_root_password = data.yandex_lockbox_secret_version.mysql_logopass.entries[1].text_value
    mysql_user          = data.yandex_lockbox_secret_version.mysql_logopass.entries[0].key
    mysql_password      = data.yandex_lockbox_secret_version.mysql_logopass.entries[0].text_value
  })
}

resource "null_resource" "archive_webserver" {
  depends_on = [local_file.compose_init, local_file.env]
  triggers = {
    compose_init = local_file.compose_init.id
  }
  provisioner "local-exec" {
    command = "tar czf archive.tar.gz webserver_src"
  }
}

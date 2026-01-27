locals {

  web_list = [
    for webRes in yandex_compute_instance.web : {
      name = webRes.name,
      id   = webRes.id,
      fqdn = webRes.fqdn
    }
  ]
  db_list = [
    for dbName, dbRes in yandex_compute_instance.db : {
      name = dbRes.name,
      id   = dbRes.id,
      fqdn = dbRes.fqdn
    }
  ]
  storage_list = [{
    name = yandex_compute_instance.storage.name,
    id   = yandex_compute_instance.storage.id,
    fqdn = yandex_compute_instance.storage.fqdn
  }]

  result_list = concat(local.web_list, local.db_list, local.storage_list)

  vpc = {
    "network_id" = "enp7i560tb28nageq0cc"
    "subnet_ids" = [
      "e9b0le401619ngf4h68n",
      "e2lbar6u8b2ftd7f5hia",
      "b0ca48coorjjq93u36pl",
      "fl8ner8rjsio6rcpcf0h",
    ]
    "subnet_zones" = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-c",
      "ru-central1-d",
    ]
  }
}

output "resources_info" {
  value = local.result_list
}

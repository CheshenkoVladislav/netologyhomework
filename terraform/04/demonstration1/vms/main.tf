#создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop"
}

#создаем подсеть
resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "develop-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}


module "marketing-vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=4d05fab828b1fcae16556a4d167134efca2fccf2"
  env_name       = "develop"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-a", "ru-central1-b"]
  subnet_ids     = [yandex_vpc_subnet.develop_a.id, yandex_vpc_subnet.develop_b.id]
  instance_name  = "marketing-develop"
  instance_count = 2
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    owner   = "i.ivanov-d",
    project = "marketing"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }
}

module "analytics-vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=4d05fab828b1fcae16556a4d167134efca2fccf2"
  env_name       = "stage"
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [yandex_vpc_subnet.develop_a.id]
  instance_name  = "analytics-stage"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    owner   = "i.ivanov",
    project = "analytics"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }
}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    public_key = file(var.public_key)
  }
}


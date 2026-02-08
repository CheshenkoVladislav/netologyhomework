resource "yandex_vpc_security_group" "netologia_project_1_sg" {
  name        = "web_sg"
  description = "Project 1 Security group"
  network_id  = yandex_vpc_network.netologia_project_1_network.id

  egress {
    description       = "All"
    protocol          = "ANY"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    description    = "SSH rule"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
    protocol       = "TCP"
  }

  ingress {
    description    = "HTTP rule"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8090
    protocol       = "TCP"
  }

  labels = {
    tag = "${local.tag}_web_sg"
  }
}

resource "yandex_vpc_subnet" "netologia_project_1_subnet" {
  v4_cidr_blocks = ["10.0.1.0/24"]
  network_id     = yandex_vpc_network.netologia_project_1_network.id
  zone           = var.zone
}

locals {
  resource_config = {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
}

data "yandex_compute_image" "ubuntu-2204-lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "web_instance" {
  depends_on  = [null_resource.archive_webserver, module.mysql]
  name        = "netologia_project_1_web_instance"
  platform_id = "standard-v3"

  resources {
    cores         = local.resource_config.cores
    memory        = local.resource_config.memory
    core_fraction = local.resource_config.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2204-lts.image_id
    }
  }

  network_interface {
    index     = 1
    subnet_id = yandex_vpc_subnet.netologia_project_1_subnet.id
    security_group_ids = [yandex_vpc_security_group.netologia_project_1_sg.id]
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = data.cloudinit_config.web_init.rendered
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/yacloud_ssh")
    host        = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir project"
    ]
  }

  provisioner "file" {
    source      = "archive.tar.gz"
    destination = "/home/ubuntu/project/archive.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~/project && tar -xvzf archive.tar.gz && cd webserver_src",
      "cloud-init status --wait",
      "sudo docker compose up -d"
    ]
  }
}

output "web_out" {
  value = yandex_compute_instance.web_instance.fqdn
}

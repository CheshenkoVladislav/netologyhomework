resource "local_file" "ansible_init" {
   content = templatefile(
      "hosts.tftpl",
      {
        webservers = yandex_compute_instance.web
        databases = yandex_compute_instance.db
        storage = yandex_compute_instance.storage
      }
    )
    filename = "ansible.cfg"
}

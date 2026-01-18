output "instance_name" {
    value = [
        yandex_compute_instance.platform.name,
        yandex_compute_instance.platform.fqdn,
        yandex_compute_instance.platform-db.name,
        yandex_compute_instance.platform-db.fqdn,
    ]
    description = "Имена ВМ"
}
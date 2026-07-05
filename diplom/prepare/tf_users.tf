resource "yandex_iam_service_account" "netology-service-account" {
  name      = "netology-service"
  folder_id = var.folder_id
}

resource "yandex_iam_service_account_iam_binding" "editor-account-iam" {
  service_account_id = yandex_iam_service_account.netology-service-account.id
  role               = "editor"

  members = [
    "userAccount:${var.yc_account_id}",
  ]
}

output "service_account_info" {
  value = yandex_iam_service_account.netology-service-account
}

# resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
#   service_account_id = yandex_iam_service_account.netology-service-account.id
#   description        = "static access key for object storage"
#   pgp_key            = "keybase:netology-service"
# }

# output "service_account_token" {
#   value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
#   sensitive = true
# }
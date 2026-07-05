resource "yandex_kms_symmetric_key" "my_key" {
  name = "symmetric-encryption-key-name"
}

resource "yandex_kms_symmetric_key_iam_binding" "access_rights" {
    symmetric_key_id = yandex_kms_symmetric_key.my_key.id
    role = "kms.keys.encrypterDecrypter"

    members = [
        "userAccount:${yandex_iam_service_account.netology-service-account.id}"
    ]
}

###cloud vars

variable "public_key" {
  type    = string
  default = "~/.ssh/yacloud_ssh.pub"
}

variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "ip_address" {
  type = string
  default = "192.168.0.1/24"
  description = "ip-адрес"
  validation {
    condition = try(cidrhost(strcontains(var.ip_address, "/") ? var.ip_address : "${var.ip_address}/24", 0), null) != null
    error_message = "Значение не является cidr-хостом"
  }
}

variable "ip_address_list" {
  type = list(string)
  description = "Список ip-адресов"
  default = [ "192.168.1.124", "192.168.0.1/24" ]
  validation {
    condition = alltrue([for address in var.ip_address_list : try(cidrhost(strcontains(address, "/") ? address : "${address}/24", 0), null) != null])
    error_message = "Все значения должны быть cidr-хостами"
  }
}

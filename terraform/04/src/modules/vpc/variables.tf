# variable "zone" {
#   type = string
# }

# variable "v4_cidr_blocks" {
#   type = list(string)
# }

# variable "subnet_name" {
#   type = string
# }

variable "net_name" {
  type = string
}

variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
}

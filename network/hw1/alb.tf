# resource "yandex_alb_target_group" "web_alb_tg" {
#   name      = "web-alb-target-group"
#   folder_id = var.folder_id

#   dynamic "target" {
#     for_each = yandex_compute_instance_group.web.instances
#     content {
#       subnet_id  = target.value.network_interface[0].subnet_id
#       ip_address = target.value.network_interface[0].ip_address
#     }
#   }
# }

# resource "yandex_alb_backend_group" "web_alb_bg" {
#   name = "web"

#   http_backend {
#     name             = "web"
#     weight           = 1
#     port             = 80
#     target_group_ids = ["${yandex_alb_target_group.web_alb_tg.id}"]
#     load_balancing_config {
#       panic_threshold = 50
#       mode            = "ROUND_ROBIN"
#     }
#     healthcheck {
#       timeout  = "2s"
#       interval = "3s"
#       http_healthcheck {
#         path = "/"
#       }
#     }
#   }
# }

# resource "yandex_alb_http_router" "http-alb" {
#   name = "http-alb"
# }

# resource "yandex_alb_virtual_host" "http" {
#   name           = "http"
#   http_router_id = yandex_alb_http_router.http-alb.id
#   route {
#     name = "web"
#     http_route {
#       http_match {
#         path {
#           exact = "/web"
#         }
#       }
#       http_route_action {
#         backend_group_id = yandex_alb_backend_group.web_alb_bg.id
#         timeout          = "3s"
#         prefix_rewrite = "/"
#       }
#     }
#   }
# }

# resource "yandex_alb_load_balancer" "my_alb" {
#   name = "my-app-load-balancer"

#   network_id = yandex_vpc_network.network.id

#   allocation_policy {
#     location {
#       zone_id   = "ru-central1-a"
#       subnet_id = yandex_vpc_subnet.public.id
#     }
#   }

#   listener {
#     name = "my-listener"
#     endpoint {
#       address {
#         external_ipv4_address {
#         }
#       }
#       ports = [80]
#     }
#     http {
#       handler {
#         http_router_id = yandex_alb_http_router.http-alb.id
#       }
#     }
#   }

#   log_options {
#     discard_rule {
#       http_code_intervals = ["HTTP_2XX"]
#       discard_percent     = 75
#     }
#   }
# }

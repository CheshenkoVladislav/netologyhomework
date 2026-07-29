# resource "null_resource" "init-kubectl-config" {
#   depends_on = [yandex_kubernetes_cluster.regional_cluster]

#   provisioner "local-exec" {
#     command = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.regional_cluster.id} --external --force"
#   }
# }

# resource "null_resource" "run_script" {
#   depends_on = [null_resource.init-kubectl-config, yandex_kubernetes_node_group.node_group]

#   provisioner "local-exec" {
#     command = <<-EOT
#     kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml &&
#     helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/gwin/charts/gwin-chart \
#         --version v1.8.2 \
#         --untar &&
#     helm install \
#         --namespace alb-diplom-cluster \
#         --create-namespace \
#         --set controller.folderId=${var.folder_id} \
#         --set-file controller.ycServiceAccount.secret.value=./prepare.json \
#     gwin ./gwin-chart
#     EOT
#   }
# }
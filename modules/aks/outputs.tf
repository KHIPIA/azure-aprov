output "aks_name" {
  description = "Nombre del cluster AKS creado."
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config_raw" {
  description = "Kubeconfig del cluster. Usar con precaución."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_object_id" {
  description = "Object ID de la identidad kubelet (para asignarle AcrPull sobre el ACR)."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

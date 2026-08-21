output "id" {
  description = "The Kubernetes Managed Cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "name" {
  description = "The Kubernetes Managed Cluster Name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_raw" {
  description = "Raw Kubernetes config to connect to the cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "The object ID of the kubelet identity of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

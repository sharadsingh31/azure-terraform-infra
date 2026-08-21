resource_groups = {
  "rg-devops-dev-01" = {
    location = "eastus"
    tags = {
      Environment = "Development"
      Project     = "DevOps-Demo"
      ManagedBy   = "Terraform"
    }
  }
}

container_registries = {
  # Note: ACR names must be alphanumeric and globally unique across Azure. Change this to a unique value.
  "acrdevopssh" = {
    resource_group_key = "rg-devops-dev-01"
    sku                = "Standard"
    admin_enabled      = false
    tags = {
      Environment = "Development"
    }
  }
}

kubernetes_clusters = {
  "aks-devops-dev-01" = {
    resource_group_key     = "rg-devops-dev-01"
    dns_prefix             = "aksdevopsdemotoday"
    kubernetes_version     = "1.29" # Ensure this version is supported in your region
    default_node_pool_name = "system"
    node_count             = 2
    vm_size                = "Standard_D2s_v3"
    os_disk_size_gb        = 30
    acr_key                = "acrdevopsdemotoday01" # Must match the key in container_registries
    tags = {
      Environment = "Development"
    }
  }
}

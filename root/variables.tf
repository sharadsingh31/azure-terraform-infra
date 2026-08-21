variable "resource_groups" {
  description = "Map of resource groups to create"
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
  default = {}
}

variable "container_registries" {
  description = "Map of Container Registries to create"
  type = map(object({
    resource_group_key = string # References key in resource_groups map
    sku                = optional(string, "Standard")
    admin_enabled      = optional(bool, false)
    tags               = optional(map(string), {})
  }))
  default = {}
}

variable "kubernetes_clusters" {
  description = "Map of AKS clusters to create"
  type = map(object({
    resource_group_key     = string # References key in resource_groups map
    dns_prefix             = string
    kubernetes_version     = optional(string)
    default_node_pool_name = optional(string, "default")
    node_count             = optional(number, 1)
    vm_size                = optional(string, "Standard_D2s_v3")
    os_disk_size_gb        = optional(number, 30)
    acr_key                = optional(string) # References key in container_registries map for AcrPull attachment
    tags                   = optional(map(string), {})
  }))
  default = {}
}

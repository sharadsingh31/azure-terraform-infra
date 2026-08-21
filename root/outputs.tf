output "resource_groups" {
  description = "Outputs of the created resource groups"
  value = {
    for k, v in module.resource_group : k => {
      id       = v.id
      name     = v.name
      location = v.location
    }
  }
}

output "container_registries" {
  description = "Outputs of the created container registries"
  value = {
    for k, v in module.acr : k => {
      id           = v.id
      name         = v.name
      login_server = v.login_server
    }
  }
}

output "kubernetes_clusters" {
  description = "Outputs of the created Kubernetes clusters"
  value = {
    for k, v in module.aks : k => {
      id   = v.id
      name = v.name
    }
  }
  sensitive = true
}

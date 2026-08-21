# Create Resource Groups
module "resource_group" {
  source   = "../modules/resource_group"
  for_each = var.resource_groups

  resource_group_name = each.key
  location            = each.value.location
  tags                = each.value.tags
}

# Create Container Registries
module "acr" {
  source   = "../modules/acr"
  for_each = var.container_registries

  registry_name       = each.key
  resource_group_name = module.resource_group[each.value.resource_group_key].name
  location            = module.resource_group[each.value.resource_group_key].location
  sku                 = each.value.sku
  admin_enabled       = each.value.admin_enabled
  tags                = each.value.tags

  depends_on = [module.resource_group]
}

# Create Azure Kubernetes Service clusters
module "aks" {
  source   = "../modules/aks"
  for_each = var.kubernetes_clusters

  cluster_name           = each.key
  resource_group_name    = module.resource_group[each.value.resource_group_key].name
  location               = module.resource_group[each.value.resource_group_key].location
  dns_prefix             = each.value.dns_prefix
  kubernetes_version     = each.value.kubernetes_version
  default_node_pool_name = each.value.default_node_pool_name
  node_count             = each.value.node_count
  vm_size                = each.value.vm_size
  os_disk_size_gb        = each.value.os_disk_size_gb
  tags                   = each.value.tags

  depends_on = [module.resource_group]
}

# Role Assignment: Grant AKS Kubelet Identity AcrPull on the specified ACR
locals {
  aks_acr_attachments = [
    for aks_key, aks_val in var.kubernetes_clusters : {
      key       = "${aks_key}-${aks_val.acr_key}"
      aks_key   = aks_key
      acr_key   = aks_val.acr_key
      acr_id    = module.acr[aks_val.acr_key].id
      principal = module.aks[aks_key].kubelet_identity_object_id
    }
    if lookup(aks_val, "acr_key", null) != null && lookup(var.container_registries, lookup(aks_val, "acr_key", ""), null) != null
  ]
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  for_each = { for attachment in local.aks_acr_attachments : attachment.key => attachment }

  scope                            = each.value.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = each.value.principal
  skip_service_principal_aad_check = true
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the AKS cluster should be created"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS cluster"
  type        = string
  default     = null
}

variable "default_node_pool_name" {
  description = "The name of the default node pool"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "The initial number of nodes which should exist in this Node Pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "The size of each VM in the Node Pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "os_disk_size_gb" {
  description = "The size of the OS Disk which should be used for each Agent in the Node Pool"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

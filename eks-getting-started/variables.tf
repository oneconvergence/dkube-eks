#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}

variable "kubernetes_version" {
  default = "1.12"
  type = "string"
}

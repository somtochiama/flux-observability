variable "name" {
    type = string
    default = "flux-observability"
}

variable "service_account_name" {
    type = string
    default = "flux-gitops-gcr"
}

variable "namespace" {
    type = string
    default = "flux-system"
}

variable "k8s_serviceaccount" {
    type = string
    default = "image-reflector-controller"
}

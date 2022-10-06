output "kubeconfig" {
  description = "kubeconfig of the created GKE cluster"
  value       = module.gke_auth.kubeconfig_raw
  sensitive   = true
}

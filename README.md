# flux-observability
Different observability solutions with/for Flux in one repo

# Steps
1. To create infrastructure, cd into terraform folder and run `terraform apply`
2. Bootstrap Flux
```
flux bootstrap github --owner somtochiama --repository flux-observability  --path=clusters/my-clusters --components-extra image-reflector-controller,image-automation-controller --read-write-key
```
3. Add yaml files for notifications - Alert + Provider
4. Add yaml files for sources and config of yaml
```
flux create source git flux-monitoring \         
  --interval=30m \
  --url=https://github.com/fluxcd/flux2 \
  --branch=main --export > clusters/my-clusters/monitoring/source.yaml

flux create kustomization kube-prometheus-stack \
  --interval=1h \
  --prune \
  --source=flux-monitoring \
  --path="./manifests/monitoring/kube-prometheus-stack" \
  --health-check-timeout=5m \
  --wait --export > clusters/my-clusters/monitoring/ks.yaml
```
5. 


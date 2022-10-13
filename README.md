# flux-observability
Different observability solutions with/for Flux in one repo

# Steps
1. To create infrastructure, cd into terraform folder and run `terraform apply`
2. Bootstrap Flux
```
flux bootstrap github --owner somtochiama --repository flux-observability  --path=clusters/my-clusters --components-extra image-reflector-controller,image-automation-controller --read-write-key
```
3. Create a slack webhook URL for Slack Provider

[Webhook Link](https://testflux.slack.com/services/B041D3SPU2W)
Slack Docs on Webhooks [docs](https://api.slack.com/messaging/webhooks)
```
## replace in secret yaml? For easier encryption?
kubectl create secret generic provider-url \
--from-literal=address=<slack-webhook> \
--dry-run=client -oyaml > ./clusters/my-clusters/notifications/secret.yaml
```
4. Create webhook-token for receiver

4. You can encrypt the secret using SOPS in flux
```
sops --encrypt --in-place clusters/my-clusters/secret.yaml
```
Encrypting Secrets using Mozilla SOPS [docs](https://fluxcd.io/flux/guides/mozilla-sops/#encrypting-secrets-using-various-cloud-providers)

5. Create Alert + Provider
```
lux create alert flux-system \
--provider-ref slack \
--event-source "GitRepository/*" \
--event-source "OCIRepository/*" \
--event-source "Kustomization/*" \
--event-source "HelmRepository/*" \
--export >> ./clusters/my-clusters/notification/alert.yaml

flux create alert-provider slack --type slack --secret-ref provider-url --export \
>> ./clusters/my-clusters/notification/provider.yaml
```
6. Create receiver
```
flux create receiver github --type github --event push,ping --secret-ref flux-system --resource GitRepository/flux-system --export >> ./clusters/my-clusters/notifications/receiver.yaml 
```

6. Create an app so that the controller can notify about it 
```
flux create source oci podinfo \
  --url=oci://ghcr.io/stefanprodan/manifests/podinfo \
  --tag=6.1.6 \
  --interval=10m --export > ./clusters/my-clusters/notification/apps.yaml

flux create kustomization podinfo \
  --source=OCIRepository/podinfo \
  --target-namespace=default \
  --prune=true \
  --interval=5m --export >> ./clusters/my-clusters/notification/apps.yaml
```


## Kube-prometheus stack
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

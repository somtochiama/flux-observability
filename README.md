# flux-observability
Different observability solutions with/for Flux in one repo

# Steps
1. To create infrastructure, cd into terraform folder and run `terraform apply`
2. Bootstrap Flux
```
flux bootstrap github --owner somtochiama --repository flux-observability  --path=clusters/my-clusters --components-extra image-reflector-controller,image-automation-controller --read-write-key
```
3. Setup Notification


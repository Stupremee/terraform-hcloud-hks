apiVersion: v1
kind: Secret
metadata:
  name: hcloud
  namespace: kube-system
type: Opaque
data:
  token: ${token}
  network: ${network}

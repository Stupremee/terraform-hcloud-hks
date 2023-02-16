apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: cert-manager
  namespace: cert-manager
spec:
  chart: cert-manager
  version: v1.10.1
  repo: https://charts.jetstack.io
  targetNamespace: cert-manager
  valuesContent: |-
    installCRDs: true
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
 name: letsencrypt-staging
 namespace: cert-manager
spec:
 acme:
   server: https://acme-staging-v02.api.letsencrypt.org/directory
   email: ${email}

   privateKeySecretRef:
     name: letsencrypt-staging

   solvers:
   - http01:
       ingress:
         class: nginx
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
 name: letsencrypt-prod
 namespace: cert-manager
spec:
 acme:
   server: https://acme-v02.api.letsencrypt.org/directory
   email: ${email}

   privateKeySecretRef:
     name: letsencrypt-prod

   solvers:
   - http01:
       ingress:
         class: nginx

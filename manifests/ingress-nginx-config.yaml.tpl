apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-ingress-nginx
  namespace: kube-system
spec:
  valuesContent: |-
    controller:
      service:
        enabled: true
        type: LoadBalancer
        annotations:
          "load-balancer.hetzner.cloud/use-private-ip": "true"
          "load-balancer.hetzner.cloud/name": "${name}"
          "load-balancer.hetzner.cloud/location": "${location}"
          "load-balancer.hetzner.cloud/type": "${type}"

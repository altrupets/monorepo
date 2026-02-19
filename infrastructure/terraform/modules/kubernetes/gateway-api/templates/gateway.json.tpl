{
  "apiVersion": "gateway.networking.k8s.io/v1",
  "kind": "Gateway",
  "metadata": {
    "name": "${gateway_name}",
    "namespace": "${namespace}",
    "annotations": {
      "app.kubernetes.io/managed-by": "terraform"
    }
  },
  "spec": {
    "gatewayClassName": "${gateway_class_name}",
    "listeners": [
      {
        "name": "http",
        "protocol": "HTTP",
        "port": 80,
        "allowedRoutes": {
          "namespaces": {
            "from": "All"
          }
        }
      }%{ if enable_https }
      ,{
        "name": "https",
        "protocol": "HTTPS",
        "port": 443,
        "tls": {
          "mode": "Terminate",
          "certificateRefs": [
            {
              "name": "${tls_secret_name}",
              "namespace": "${tls_namespace}"
            }
          ]
        },
        "allowedRoutes": {
          "namespaces": {
            "from": "All"
          }
        }
      }%{ endif }
    ]
  }
}

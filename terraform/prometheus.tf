# Deploying the Prometheus Operator
data "kubectl_file_documents" "prometheus" {
    content = file("../manifests/argocd/prometheus-operator.yaml")
}

resource "kubectl_manifest" "prometheus" {
    depends_on = [
      kubectl_manifest.ingress_argocd
    ]
    count     = length(data.kubectl_file_documents.prometheus.documents)
    yaml_body = element(data.kubectl_file_documents.prometheus.documents, count.index)
    override_namespace = "argocd"
}

# Exposing Prometheus as NodePort
data "kubectl_file_documents" "prometheus_expose" {
    content = file("../manifests/argocd/prometheus-expose.yaml")
}

resource "kubectl_manifest" "prometheus_expose" {
    depends_on = [
      kubectl_manifest.prometheus
    ]
    count     = length(data.kubectl_file_documents.prometheus_expose.documents)
    yaml_body = element(data.kubectl_file_documents.prometheus_expose.documents, count.index)
    override_namespace = "argocd"
}
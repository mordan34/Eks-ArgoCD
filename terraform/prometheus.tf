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
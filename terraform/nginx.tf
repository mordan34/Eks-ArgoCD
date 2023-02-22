# Deploying the nginx Application
data "kubectl_file_documents" "nginx" {
    content = file("../manifests/argocd/nginx.yaml")
}

resource "kubectl_manifest" "nginx" {
    depends_on = [
      kubectl_manifest.ingress_argocd
    ]
    count     = 0 #length(data.kubectl_file_documents.nginx.documents)
    yaml_body = element(data.kubectl_file_documents.nginx.documents, count.index)
    override_namespace = "argocd"
}
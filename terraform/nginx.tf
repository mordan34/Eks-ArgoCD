# Deploying the nginx Application
data "kubectl_filename_list" "manifests" {
    pattern = "../manifests/argocd/nginx/*.yaml"
}

resource "kubectl_manifest" "nginx" {
    count     = 0 #length(data.kubectl_filename_list.manifests.matches)
    yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
    override_namespace = var.argo_ns

    depends_on = [
      kubectl_manifest.ingress_argocd
    ]
}
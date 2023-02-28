# Deploying the nginx Application
data "kubectl_filename_list" "manifests" {
    pattern = "../manifests/argocd/nginx/*.yaml"
}

resource "kubectl_manifest" "nginx" {
    count     = length(data.kubectl_filename_list.manifests.matches)
    yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
    override_namespace = "argocd"

    depends_on = [
      kubectl_manifest.ingress_argocd
    ]
}
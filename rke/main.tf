resource "rke_cluster" "cluster" {
  nodes {
    address = "NODEIP"
    user    = "NODEUSER"
    role    = ["controlplane", "worker", "etcd"]
    ssh_key = file("SSHKEYPATH")
  }
  kubernetes_version = "v1.16.15-rancher1-3"
  network {
    plugin = "flannel"
  }
  services {
    kubelet {
      extra_args = {
        max_pods = POD_COUNT
      }
    }
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  sensitive_content  = rke_cluster.cluster.kube_config_yaml
}

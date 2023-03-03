resource "rke_cluster" "cluster" {
  nodes {
    address = "NODEIP"
    user    = "NODEUSER"
    role    = ["controlplane", "worker", "etcd"]
    ssh_key = file("SSHKEYPATH")
  }
  kubernetes_version = "v1.21.14-rancher1-1"
  network {
    mtu = 0
    options = {
      flannel_backend_type = "vxlan"
    }
    plugin = "canal"
  }
  services {
    kube_api {
      extra_args = {
        service-account-issuer = "kubernetes.default.svc"
        service-account-signing-key-file = "/etc/kubernetes/ssl/kube-service-account-token-key.pem"
      }
    }
    kube_controller {
      extra_args = {
        cluster-signing-cert-file = "/etc/kubernetes/ssl/kube-ca.pem"
        cluster-signing-key-file = "/etc/kubernetes/ssl/kube-ca-key.pem"
      }
    }
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

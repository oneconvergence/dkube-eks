terraform {
  required_providers {
    rke = {
      source = "rancher/rke"
      version = "1.4.0"
    }
  }
}

provider "rke" {
  debug = true
  log_file = "rke_debug.log"
}

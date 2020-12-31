provider "google" {
  credentials = file("credentials.json")
  project     = "dkube-public"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_firewall" "allow-http" {
    name = "allow-http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http"]
}

resource "google_compute_instance" "INSTANCE_NAME" {
  count        = 1
  name         = "INSTANCE_NAME"
  machine_type = "n1-standard-32"
  zone         = "us-central1-c"

  tags = ["http"]

 boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
      size = 300
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP - leaving this block empty will generate a new external IP and assign it to the machine
    }
  }

  guest_accelerator{
    type = "nvidia-tesla-k80" // Type of GPU attahced
    count = 4 // Num of GPU attached
  }

  scheduling{
    on_host_maintenance = "TERMINATE" // Need to terminate GPU on maintenance
  }

  metadata = {
    disable-legacy-endpoints = "true"
    ssh-keys = "ubuntu:${file("ssh-rsa.pub")}"
  }

  metadata_startup_script = file("startup.sh")
}

output "ip_address" {
  value = google_compute_instance.INSTANCE_NAME.*.network_interface[0].0.access_config.0.nat_ip
}

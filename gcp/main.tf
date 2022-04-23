resource "google_compute_instance" "default" {
  name         = var.name
  machine_type = var.machine
  zone         = var.zone

  boot_disk {
    initialize_params {
      size  = var.disk_size
      type  = "pd-ssd"
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  guest_accelerator {
    type  = "nvidia-tesla-t4"
    count = 1
  }

  scheduling {
    preemptible         = var.preemptible
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
  }

  metadata = {
    install-nvidia-driver = "True"
  }

  metadata_startup_script = "git clone https://github.com/sskorol/vosk-api-gpu.git /tmp/vosk"
}

# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  required_version = ">= 1.0.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a persistent disk for Uptime Kuma data
resource "google_compute_disk" "kuma_disk" {
  name = "kuma-disk"
  type = "pd-standard"
  size = var.disk_size
  zone = var.zone
}

# Create VPC network firewall rule for Uptime Kuma
resource "google_compute_firewall" "kuma_firewall" {
  name    = "allow-kuma-3001"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3001"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kuma-3001"]
}

# Create the VM instance
resource "google_compute_instance" "uptime_kuma" {
  name         = "uptime-kuma-vm"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["kuma-3001"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = var.boot_disk_size
    }
  }

  attached_disk {
    source      = google_compute_disk.kuma_disk.self_link
    device_name = "kuma-data"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    google-logging-enabled = "true"
    
    # Configure the container
    gce-container-declaration = yamlencode({
      spec = {
        containers = [{
          name = "uptime-kuma"
          image = "registry.hub.docker.com/louislam/uptime-kuma:1-debian"
          securityContext = {
            privileged = false
          }
          volumeMounts = [{
            name = "kuma-data"
            mountPath = "/app/data"
            readOnly = false
          }]
          ports = [{
            containerPort = 3001
            hostPort = 3001
          }]
        }]
        volumes = [{
          name = "kuma-data"
          hostPath = {
            path = "/mnt/disks/kuma-data"
          }
        }]
        restartPolicy = "Always"
      }
    })
    
    # Format and mount the persistent disk
    startup-script = <<-EOF
      #!/bin/bash
      if [ ! -d "/mnt/disks/kuma-data" ]; then
        sudo mkdir -p /mnt/disks/kuma-data
        sudo mkfs.ext4 -F /dev/disk/by-id/google-kuma-data
        sudo mount -o discard,defaults /dev/disk/by-id/google-kuma-data /mnt/disks/kuma-data
        sudo chmod a+w /mnt/disks/kuma-data
      fi
    EOF
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# outputs.tf
output "instance_external_ip" {
  value       = google_compute_instance.uptime_kuma.network_interface[0].access_config[0].nat_ip
  description = "The external IP address of the Uptime Kuma instance"
}

output "uptime_kuma_url" {
  value       = "http://${google_compute_instance.uptime_kuma.network_interface[0].access_config[0].nat_ip}:3001"
  description = "The URL to access Uptime Kuma"
}
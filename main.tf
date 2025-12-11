# Instance Template
resource "google_compute_instance_template" "tpl" {
  name_prefix  = "lb-backend-template-"
  machine_type = "e2-micro"
  tags         = ["allow-health-check"]

  network_interface {
    network = "default"
    access_config {
      # Public IP
    }
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  metadata_startup_script = <<EOF
    #! /bin/bash
    apt-get update
    apt-get install -y apache2
    echo "<h1>Hello from LB Backend at $(hostname)</h1>" > /var/www/html/index.html
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Managed Instance Group
resource "google_compute_region_instance_group_manager" "mig" {
  name               = "lb-backend-mig"
  region             = var.region
  base_instance_name = "lb-backend"
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.tpl.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

# Health Check
resource "google_compute_health_check" "default" {
  name = "http-basic-check"

  tcp_health_check {
    port = 80
  }
}

# Backend Service
resource "google_compute_backend_service" "default" {
  name          = "web-backend-service"
  health_checks = [google_compute_health_check.default.id]
  port_name     = "http"
  protocol      = "HTTP"

  backend {
    group = google_compute_region_instance_group_manager.mig.instance_group
  }
}

# URL Map
resource "google_compute_url_map" "default" {
  name            = "web-map"
  default_service = google_compute_backend_service.default.id
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "web-proxy"
  url_map = google_compute_url_map.default.id
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  name       = "web-rule"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
}

# Firewall Rule for Health Checks
# Google Cloud Load Balancer IPs: 130.211.0.0/22 and 35.191.0.0/16
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
}

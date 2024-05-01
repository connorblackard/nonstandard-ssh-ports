provider "google" {
  project = "project_name"
  region  = "us-central1"
  zone    = "us-central1-c"
}

variable "ssh_ports" {
  type    = list(string)
  default = ["22", "2222", "200", "42978", "55755"]

}

resource "google_compute_instance" "ssh-instances" {
  count = length(var.ssh_ports)  
  name         = "ssh-port-${var.ssh_ports[count.index]}"
  machine_type = "e2-micro"
  tags = ["ssh-port-${var.ssh_ports[count.index]}"]
  metadata_startup_script = "sed -i \"s/#Port 22/Port ${var.ssh_ports[count.index]}/g\" /etc/ssh/sshd_config && sed -i \"s/PasswordAuthentication no/PasswordAuthentication yes/g\" /etc/ssh/sshd_config && systemctl restart sshd"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.ssh-network.self_link
    subnetwork = google_compute_subnetwork.ssh-network-subnet.self_link
    access_config {
    }
  }
}

resource "google_compute_network" "ssh-network" {
  name                    = "ssh-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "ssh-network-subnet" {
  name          = "ssh-network-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.ssh-network.self_link
}


resource "google_compute_firewall" "ssh-rules" {
  count = length(var.ssh_ports)
  name    = "ssh-port-${var.ssh_ports[count.index]}"
  network = google_compute_network.ssh-network.self_link

  allow {
    protocol = "tcp"
    ports    = ["${var.ssh_ports[count.index]}"]
  }
  target_tags = ["ssh-port-${var.ssh_ports[count.index]}"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp-rule" {
  name    = "icmp-rule"
  network = google_compute_network.ssh-network.self_link
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}
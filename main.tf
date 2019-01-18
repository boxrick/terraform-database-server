# Database module

# Google Provider
provider "google" {

  # Loaded in from environment
  # export GCLOUD_KEYFILE_JSON=~/.config/gcloud/admin.json
  project = "${var.project}"
  region = "${var.region}"
}

# Generate random ID
resource "random_id" "random" {
  keepers = {
    id = "1"
  }
  byte_length = 8
}

# Set a static external IP
resource "google_compute_address" "static-ip-address" {
  count        = "${var.database_instance_count}"
  name         = "${var.database_name}-static-ip-${random_id.random.hex}-${count.index}"
}

# Compute instance
resource "google_compute_instance" "database-instance" {
  count        = "${var.database_instance_count}"
  name         = "${var.database_name}-${random_id.random.hex}-${count.index}"
  machine_type = "${var.database_machine_type}"

  zone = "${var.region}-${var.zone}"

  min_cpu_platform = "Intel Skylake"

  tags = "${var.database_network_tags}"

  boot_disk {
    initialize_params {
      image = "centos-7"
      type  = "pd-ssd"
      size  = "25"
    }
  }

  attached_disk {
    source      = "${element(local.this_database_disk_self_link, count.index)}"
    device_name = "${element(local.this_database_disk_self_name, count.index)}"
  }

  network_interface {
    subnetwork    = "${var.database_subnetwork}"
    access_config {
      nat_ip = "${element(google_compute_address.static-ip-address.*.address, count.index)}"
    }
  }

  service_account {
    scopes = "${var.permission_scopes}"
  }

  # Decide if we want a pre-emptable instance or standard based on conditional
  scheduling {
    on_host_maintenance = "${var.preemptible ? "TERMINATE" : "MIGRATE"}"
    preemptible         = "${var.preemptible ? "true" : "false"}"
    automatic_restart   = "${var.preemptible ? "false" : "true"}"
  }
}

# Create a disk image resource, allows us to use family without destroy disk each time
data "google_compute_image" "disk-image" {
  count = "${var.database_instance_count}"
  family  = "${var.database_disk_image_name}"
  project = "${var.database_disk_image_project}"
}

# We need two compute disk resources here, this allows us to have a life cycle option
# allowing us to control if a new image is used in the lifecycle section

# The below resources are mutually exclusive, we need to use one or the other but refer to them with a single variable
# the local below allows us to do this
locals {
  this_database_disk_self_link = "${compact(concat(coalescelist(google_compute_disk.database-instance-disk.*.self_link, google_compute_disk.database-instance-disk-other.*.self_link), list("")))}"
  this_database_disk_self_name = "${compact(concat(coalescelist(google_compute_disk.database-instance-disk.*.name, google_compute_disk.database-instance-disk-other.*.name), list("")))}"
}


resource "google_compute_disk" "database-instance-disk" {
  count = "${var.database_instance_count * var.ignore_new_images}"
  name  = "${var.database_name}-disk-${random_id.random.hex}-${count.index}"
  type  = "pd-ssd"
  image = "${element(data.google_compute_image.disk-image.*.self_link, count.index)}"
  zone  = "${var.region}-${var.zone}"
  size  = "500"

  # If the image is updated, we should ignore it
  lifecycle {
    ignore_changes = ["image"]
  }
}

resource "google_compute_disk" "database-instance-disk-other" {
  count = "${var.database_instance_count * (1 - var.ignore_new_images)}"
  name  = "${var.database_name}-disk-${random_id.random.hex}-${count.index}"
  type  = "pd-ssd"
  image = "${element(data.google_compute_image.disk-image.*.self_link, count.index)}"
  zone  = "${var.region}-${var.zone}"
  size  = "500"
}

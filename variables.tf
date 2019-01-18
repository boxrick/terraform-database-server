# This file contains all the defaults and potential overrides for this module

variable "region" {
  default = "europe-west1"
}
variable "zone" {
  default = "d"
}
variable "project"
{
  default = "test"
}
variable "database_instance_count" {
  default = "1"
}
variable "database_base_image" {
  default = "centos7"
}
variable "database_disk_image_project" {
  default = "images"
}
variable "database_disk_image_name" {
  default = "database-image-restore"
}
variable "database_subnetwork" {
  default = "europe-west1-db"
}
variable "database_machine_type" {
  default = "n1-standard-1"
}
variable "database_network_tags" {
  type = "list"
  default = [
    "database",
    "db-server"
  ]
}
variable "permission_scopes" {
  type = "list"
  default = [
    "cloud-platform"
  ]
}
variable "preemptible" {
  default = false
}
variable "ignore_new_images" {
  description = "If this is true then we will ignore any new images published in the family"
  default = true
}

variable "database_name" {}

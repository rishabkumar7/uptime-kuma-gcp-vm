variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy resources to"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type to use for the VM instance"
  type        = string
  default     = "e2-micro"
}

variable "disk_size" {
  description = "Size of the persistent disk in GB"
  type        = number
  default     = 20
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 10
}
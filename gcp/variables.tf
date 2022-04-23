variable "name" {
  default = "gpu"
}

variable "machine" {
  default = "n1-standard-8"
}

variable "zone" {
  default = "us-central1-a"
}

variable "disk_size" {
  default = 50
}

variable "disk_image" {
  default = "projects/ml-images/global/images/c0-deeplearning-common-cu113-v20220316-debian-10"
}

variable "preemptible" {
  default = true
}

variable "project" {
  type = string
}

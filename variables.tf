variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "lb_name" {
  description = "Name for the load balancer resources"
  type        = string
  default     = "my-web-lb"
}

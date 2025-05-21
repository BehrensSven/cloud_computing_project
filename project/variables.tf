variable "ami_id" {
  type    = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
  description = "EC2 Instance Type"
}

variable "key_name" {
  type        = string
  description = "Name des EC2 Key Pairs für SSH-Zugriff"
}

variable "db_name" {
  type        = string
  default     = "django_project"
}

variable "db_username" {
  type        = string
}

variable "db_password" {
  type        = string
  sensitive   = true
}

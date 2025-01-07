variable "region" {
  description = "Region"
  default     = "us-east-1"
  type        = string
}

variable "s3-bucket-name" {
  description = "S3 bucket name"
  type        = string
}

variable "project-name" {
  description = "Name of Project"
  type        = string
}

variable "postgres-schema" {
  description = "Name of DB schema"
  type        = string
}

# variable "postgres-username" {
#   description = "Name of DB user"
#   type        = string
# }

variable "postgres-password" {
  description = "Password for PostgreSQL DB"
}
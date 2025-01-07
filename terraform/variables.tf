variable "region" {
  description = "Region"
  default     = "us-east-1"
  type        = string
}

variable "project-name" {
  description = "Name of Project"
  type        = string
}

variable "postgres-dbname" {
  description = "Name of PostgreSQL database"
  default     = "dev"
  type        = string
}

variable "postgres-schema" {
  description = "Name of DB schema"
  type        = string
}

variable "postgres-username" {
  description = "Name of DB user"
  sensitive = true
}

variable "postgres-password" {
  description = "Password for PostgreSQL DB"
  sensitive = true
  type = string
}

variable "postgres-port" {
  description = "Port on PostgreSQL DB"
  default = 5432
  type = number
}

variable "s3-bucket-name" {
  description = "S3 bucket name"
  type        = string
}
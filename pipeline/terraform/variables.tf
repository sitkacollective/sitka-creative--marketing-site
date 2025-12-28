# Variables loaded from .env file
variable "APP_NAME" {}
variable "APP_VERSION" {}
variable HOSTED_ZONE_NAME {}

# Variable from the `env_config` files
variable env_tag {}
variable "sub_domain" {}

variable "region" {
  description = "The AWS region"
  default     = "us-west-2"
}


locals {
  bucket_name = "${var.APP_NAME}-${terraform.workspace}"
  domain_name = "${var.sub_domain}${var.HOSTED_ZONE_NAME}"
}
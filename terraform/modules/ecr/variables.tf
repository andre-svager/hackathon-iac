variable "repository_names" {
  description = "One ECR repository is created per name in this list"
  type        = list(string)
}

variable "untagged_image_expiry_days" {
  type    = number
  default = 7
}

variable "max_tagged_images" {
  type    = number
  default = 10
}

variable "tags" {
  type    = map(string)
  default = {}
}

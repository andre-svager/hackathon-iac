variable "prefix" {
  description = "Path prefix all parameters are created under, e.g. /solidarytech/production"
  type        = string
}

variable "parameters" {
  description = "Map of parameter name (relative to prefix) to value"
  type        = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

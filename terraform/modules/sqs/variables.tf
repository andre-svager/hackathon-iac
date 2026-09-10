variable "name" {
  type = string
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 30
}

variable "message_retention_seconds" {
  description = "Default 4 days"
  type        = number
  default     = 345600
}

variable "dlq_message_retention_seconds" {
  description = "Default 14 days (max) so failed donation events aren't lost before investigation"
  type        = number
  default     = 1209600
}

variable "max_receive_count" {
  type    = number
  default = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}

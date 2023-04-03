variable "target_deployment_region" {
  type = string
  default = ""
}

variable "deployment_bucket_basename" {
  type = string
  default = ""
}

variable "openai_api_key" {
  type = string
  default = ""
}

variable "message_cache_expiration_in_hours" {
  type = number
  default = 8
}

variable "project" {
  type = string
  default = "chatgpt"
}


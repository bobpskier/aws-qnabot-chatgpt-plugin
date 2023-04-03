variable "region" {
  type = string
}

variable "project" {
  type = string
  default = "chatgpt"
}

variable "openai_api_key" {
  type = string
}

variable "message_cache_expiration_in_hours" {
  type = number
  default = 8
}

variable "chatgpt_model" {
  type = string
  default = "gpt-3.5-turbo"
}
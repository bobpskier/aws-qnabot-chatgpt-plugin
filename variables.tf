variable "supported_regions" {
  # default = ["us-east-1", "us-west-2", "af-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "eu-central-1", "ca-central-1", "eu-west-1", "eu-west-2"]
  default = ["us-east-1", "us-west-2"]

}

variable "target_deployment_region" {
  type = string
  default = "us-west-2"
}

variable "deployment_bucket_basename" {
  type = string
  default = "tioth-chatgpt-plugin-resources"
}

variable "openai_api_key" {
  type = string
  default = "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"
}

variable "message_cache_expiration_in_hours" {
  type = number
  default = 8
}

variable "project" {
  type = string
  default = "chatgpt-test"
}


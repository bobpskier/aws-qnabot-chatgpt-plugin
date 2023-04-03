module "chatgpt-plugin" {
  source     = "./modules/chatgpt-plugin"
  openai_api_key = var.openai_api_key
  region = var.target_deployment_region
  project = var.project
  message_cache_expiration_in_hours = var.message_cache_expiration_in_hours
}

module "deployment-us-east-1" {
  source = "./modules/deployment"
  region = "us-east-1"
}

module "deployment-us-west-2" {
  source = "./modules/deployment"
  region = "us-west-2"
}

module "deployment-ap-northeast-2" {
  source = "./modules/deployment"
  region = "ap-northeast-2"
}

module "deployment-ap-southeast-1" {
  source = "./modules/deployment"
  region = "ap-southeast-1"
}

module "deployment-ap-southeast-2" {
  source = "./modules/deployment"
  region = "ap-southeast-2"
}

module "deployment-ap-northeast-1" {
  source = "./modules/deployment"
  region = "ap-northeast-1"
}

module "deployment-eu-central-1" {
  source = "./modules/deployment"
  region = "eu-central-1"
}

module "deployment-ca-central-1" {
  source = "./modules/deployment"
  region = "ca-central-1"
}

module "deployment-eu-west-1" {
  source = "./modules/deployment"
  region = "eu-west-1"
}

module "deployment-eu-west-2" {
  source = "./modules/deployment"
  region = "eu-west-2"
}


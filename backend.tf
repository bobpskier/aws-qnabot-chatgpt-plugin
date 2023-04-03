terraform {
  backend "s3" {
    bucket = "terraform-main-us-west-2"
    key    = "chatgpt-deployment.tfstate"
    region = "us-west-2"
    encrypt = true
  }
}





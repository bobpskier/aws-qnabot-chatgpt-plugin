
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "deployment_bucket" {
  bucket = "${var.deployment_bucket_basename}-${var.region}"
}

resource "aws_s3_bucket_acl" "deployment_bucket_acl" {
  bucket = "${var.deployment_bucket_basename}-${var.region}"
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "deployment_bucket_versioning" {
  bucket = "${var.deployment_bucket_basename}-${var.region}"
  versioning_configuration {
    status = "Disabled"
  }
}

# Terraform is used to deploy these S3 objects to the deployment bucket.
# Note, they are not public-read by default. If you want to use them outside of this
# AWS Account, you'll need to use the AWS Console to make the objects public-read

resource "aws_s3_object" "plugin_layer_zip" {
  depends_on = [aws_s3_bucket_versioning.deployment_bucket_versioning]
  bucket = "${var.deployment_bucket_basename}-${var.region}"
  key    = "plugin-layer.zip"
  source = "${path.module}/../plugin-layer.zip"
  etag = filemd5("${path.module}/../plugin-layer.zip")
}

resource "aws_s3_object" "plugin_layer" {
  depends_on = [aws_s3_bucket_versioning.deployment_bucket_versioning]
  bucket = "${var.deployment_bucket_basename}-${var.region}"
  key    = "plugin.zip"
  source = "${path.module}/../plugin.zip"
  etag = filemd5("${path.module}/../plugin.zip")
}

resource "aws_s3_object" "plugin_yaml" {
  depends_on = [aws_s3_bucket_versioning.deployment_bucket_versioning]
  bucket = "${var.deployment_bucket_basename}-${var.region}"
  key    = "primary.yaml"
  source = "${path.module}/../../templates/primary.yaml"
  etag = filemd5("${path.module}/../../templates/primary.yaml")
}

resource "aws_s3_object" "chatgpt_plugin_qna_json" {
  depends_on = [aws_s3_bucket_versioning.deployment_bucket_versioning]
  bucket = "${var.deployment_bucket_basename}-${var.region}"
  key    = "chatgpt-plugin-qna.json"
  source = "${path.module}/../../chatgpt-plugin-qna.json"
  etag = filemd5("${path.module}/../../chatgpt-plugin-qna.json")
}

resource "aws_s3_object" "chatgpt_plugin_src" {
  depends_on = [aws_s3_bucket_versioning.deployment_bucket_versioning]
  bucket = "${var.deployment_bucket_basename}-${var.region}"
  key    = "src/plugin/chatgpt-router.py"
  source = "${path.module}/../chatgpt-plugin/plugin/chatgpt-router.py"
  etag = filemd5("${path.module}/../chatgpt-plugin/plugin/chatgpt-router.py")
}

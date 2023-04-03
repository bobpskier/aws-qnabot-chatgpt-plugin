# Define a role for the lambda containing the chatgpt plugin
resource "aws_iam_role" "qnabot_plugin_role" {
  name = "${local.base_prefix}-qnabot-plugin"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# Define iam role policy that allows Lambda function to update qnabot stack resources
#
resource "aws_iam_role_policy" "qnabot_chat_gpt_plugin_policy" {
  name = "${local.base_prefix}-qnabot-plugin-policy"
  role = aws_iam_role.qnabot_plugin_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "LambdaWriteToCloudWatch",
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Sid": "DynamoDB",
        "Effect": "Allow",
        "Action": [
            "dynamodb:PutItem",
            "dynamodb:Query"
        ],
        "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/QNA-${local.base_prefix}-user-cache"
      }
    ]
  }
  EOF
}

data "archive_file" "qnabot_plugin_layer" {
  type = "zip"
  source_dir = "${path.module}/plugin-layer"
  output_path = "${path.module}/plugin-layer.zip"
}

data "archive_file" "qnabot_plugin" {
  type = "zip"
  source_dir = "${path.module}/plugin"
  output_path = "${path.module}/plugin.zip"
}

resource "aws_dynamodb_table" "chatgpt-user-message-cache" {
  name           = "QNA-${local.base_prefix}-user-cache"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userid"
  range_key      = "messageTimeout"
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled = false
  }
  attribute {
    name = "userid"
    type = "S"
  }
  attribute {
    name = "messageTimeout"
    type = "N"
  }
  ttl {
    attribute_name = "messageTimeout"
    enabled        = true
  }
}

resource "aws_lambda_layer_version" "qnabot_plugin_layer" {
  layer_name = "QNA-${local.base_prefix}-qnabot-plugin-layer"
  filename = data.archive_file.qnabot_plugin_layer.output_path
  source_code_hash = data.archive_file.qnabot_plugin_layer.output_base64sha256
  compatible_runtimes = ["python3.9"]
}

# Define the Lambda function to handle updates to the QnABot Stack
resource "aws_lambda_function" "QNA-ChatGptRouter" {
  function_name                  = "QNA-${local.base_prefix}-qnabot-router"
  depends_on                     = [data.archive_file.qnabot_plugin]
  handler                        = "chatgpt-router.lambda_handler"
  filename                       = data.archive_file.qnabot_plugin.output_path
  memory_size                    = 256
  role                           = aws_iam_role.qnabot_plugin_role.arn
  runtime                        = "python3.9"
  timeout                        = 120
  layers = [aws_lambda_layer_version.qnabot_plugin_layer.arn]
  source_code_hash = data.archive_file.qnabot_plugin.output_base64sha256
  environment {
    variables = {
      ACCOUNT = data.aws_caller_identity.current.account_id
      OPENAI_API_KEY = var.openai_api_key
      CHATGPT_MODEL = var.chatgpt_model
      DYNAMODB_USER_MESSAGE_CACHE = aws_dynamodb_table.chatgpt-user-message-cache.name
      MESSAGE_CACHE_EXPIRATION_IN_HOURS = var.message_cache_expiration_in_hours
    }
  }
}

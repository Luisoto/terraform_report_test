resource "aws_iam_role" "iam_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
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

resource "aws_iam_policy" "dynamo_policy" {
  name        = "dynamo-policy"
  description = "dynamo policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamo-attach" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = aws_iam_policy.dynamo_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name = "/aws/lambda/${aws_lambda_function.qrvey_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_s3_bucket_object" "lambda_zip" {
  bucket  = var.artifact_s3_bucket
  key     = var.artifact_s3_file
}

resource "aws_lambda_function" "qrvey_lambda" {
  s3_bucket         = data.aws_s3_bucket_object.lambda_zip.bucket
  s3_key            = data.aws_s3_bucket_object.lambda_zip.key
  s3_object_version = data.aws_s3_bucket_object.lambda_zip.version_id
  function_name     = "lambda_function"
  role              = aws_iam_role.iam_lambda.arn
  handler           = "index.handler"

  runtime = "nodejs14.x"

  environment {
    variables = {
      DYNAMODB_TABLE = var.table_name
    }
  }
}
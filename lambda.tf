
# Packing lambda source code into archive
data "archive_file" "redirector-zip" {
  type        = "zip"
  output_path = "files/redirector.zip"
  source_file = "files/index.js"
}

# Lambda role used during execution
resource "aws_iam_role" "redirector-lambda-execution" {
  name_prefix        = "redirector-lambda-role-"
  description        = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Policy attached to lambda role to provide write access to CloudWatch
resource "aws_iam_role_policy" "redirector-lambda-execution-logs" {
  name_prefix = "redirector-lambda-policy-"
  role        = aws_iam_role.redirector-lambda-execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Policy attached to lambda role to provide access to DynamoDb
resource "aws_iam_role_policy" "redirector-lambda-execution-dynamodb" {
  name_prefix = "redirector-lambda-policy-"
  role        = aws_iam_role.redirector-lambda-execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Lambda function
resource "aws_lambda_function" "redirector" {
  description      = "Managed by Terraform"
  filename         = "files/redirector.zip"
  function_name    = "redirector"
  handler          = "index.handler"
  source_code_hash = data.archive_file.redirector-zip.output_base64sha256
  publish          = true
  role             = aws_iam_role.redirector-lambda-execution.arn
  runtime          = "nodejs12.x"
}

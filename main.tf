/**
 * ## Usage
 *
 * Creates an AWS Lambda Function.
 *
 * ```hcl
 * module "lambda_function" {
 *   source = "dod-iac/lambda-function/aws"
 *
 *   execution_role_name = format(
 *     "app-%s-func-lambda-execution-role-%s",
 *     var.application,
 *     var.environment
 *   )
 *
 *   function_name = format(
 *     "app-%s-func-%s-%s",
 *     var.application,
 *     var.environment,
 *     data.aws_region.current.name
 *   )
 *
 *   function_description = "Function description."
 *
 *   filename = format("../../lambda/%s-func.zip", var.application)
 *
 *   handler = "index.handler"
 *
 *   runtime = "nodejs12.x"
 *
 *   environment_variables = var.environment_variables
 *
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * Use the `execution_role_policy_document` variable to override the IAM policy document for the IAM role.
 *
 * ## Terraform Version
 *
 * Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 is not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_iam_role" "execution_role" {
  name               = var.execution_role_name
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
            "lambda.amazonaws.com"
          ]
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
  tags               = var.tags
}

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid = "CreateCloudWatchLogGroups"
    actions = [
      "logs:CreateLogGroup"
    ]
    effect = "Allow"
    resources = [
      format(
        "arn:%s:logs:*:*:log-group:/aws/lambda/*",
        data.aws_partition.current.partition
      )
    ]
  }
  statement {
    sid = "CreateCloudWatchLogStreamsAndPutLogEvents"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      format(
        "arn:%s:logs:*:*:log-group:/aws/lambda/*:log-stream:*",
        data.aws_partition.current.partition
      )
    ]
  }
}

resource "aws_iam_policy" "execution_role" {
  name   = length(var.execution_role_policy_name) > 0 ? var.execution_role_policy_name : var.execution_role_name
  path   = "/"
  policy = length(var.execution_role_policy_document) > 0 ? var.execution_role_policy_document : data.aws_iam_policy_document.execution_role.json
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.execution_role.arn
}

resource "aws_lambda_function" "main" {
  function_name    = var.function_name
  description      = var.function_description
  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)
  handler          = var.handler
  layers           = var.layers
  runtime          = var.runtime
  role             = aws_iam_role.execution_role.arn
  timeout          = var.timeout
  memory_size      = var.memory_size
  publish          = true
  environment {
    variables = var.environment_variables
  }
  tags = var.tags
}

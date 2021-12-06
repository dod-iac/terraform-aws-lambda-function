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
 * Use the optional `execution_role_policy_document` variable to override the IAM policy document for the IAM role.
 *
 * Use the optional `cloudwatch_schedule_expression` variable to schedule execution of the Lambda using CloudWatch Events.
 *
 * Use the optional `kms_key_arn` variable to encrypt the environment variables with a custom KMS key.  Use the `dod-iac/lambda-kms-key/aws` module to create a KMS key.
 *
 * Use the optional `security_group_ids` and `subnet_ids` variables to run the function within a VPC.
 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.
 *
 * ## Terraform Version
 *
 * Terraform 0.12. Pin module version to ~> 1.0.1 . Submit pull-requests to master branch.
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
  kms_key_arn      = length(var.kms_key_arn) > 0 && length(var.environment_variables) > 0 ? var.kms_key_arn : null
  runtime          = var.runtime
  role             = aws_iam_role.execution_role.arn
  timeout          = var.timeout
  memory_size      = var.memory_size
  publish          = true
  tags             = var.tags
  environment {
    variables = var.environment_variables
  }
  dynamic "vpc_config" {
    for_each = length(var.security_group_ids) > 0 && length(var.subnet_ids) > 0 ? [1] : []
    content {
      security_group_ids = var.security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }
}

#
# CloudWatch Events
#

resource "aws_cloudwatch_event_rule" "main" {
  count               = length(var.cloudwatch_schedule_expression) > 0 ? 1 : 0
  name                = length(var.cloudwatch_rule_name) > 0 ? var.cloudwatch_rule_name : var.function_name
  description         = length(var.cloudwatch_rule_description) > 0 ? var.cloudwatch_rule_description : ""
  schedule_expression = var.cloudwatch_schedule_expression
}

resource "aws_cloudwatch_event_target" "main" {
  count     = length(var.cloudwatch_schedule_expression) > 0 ? 1 : 0
  rule      = aws_cloudwatch_event_rule.main.0.name
  target_id = length(var.cloudwatch_target_id) > 0 ? var.cloudwatch_target_id : var.function_name
  arn       = aws_lambda_function.main.arn
}

resource "aws_lambda_permission" "main" {
  count         = length(var.cloudwatch_schedule_expression) > 0 ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.main.0.arn
}

#
# Event Sources
#

resource "aws_lambda_event_source_mapping" "main" {
  count            = length(var.event_sources)
  function_name    = aws_lambda_function.main.arn
  event_source_arn = var.event_sources[count.index].event_source_arn
}

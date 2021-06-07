// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

data "aws_region" "current" {}

data "archive_file" "lambda_simple_zip_inline" {
  type        = "zip"
  source_file = "${path.module}/handler.py"
  output_path = "../../temp/lambda/simple.zip"
}

module "lambda_function" {
  source = "../../"

  execution_role_name = format(
    "test-func-lambda-execution-role-%s",
    var.test_name
  )

  function_name = format(
    "test-func-%s-%s",
    var.test_name,
    data.aws_region.current.name
  )

  function_description = "Function description."

  filename = data.archive_file.lambda_simple_zip_inline.output_path

  handler = "handler.lambda_handler"

  runtime = "python3.8"

  environment_variables = {}

  tags = var.tags
}

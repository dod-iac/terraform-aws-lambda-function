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


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = format(
    "test-vpc-%s",
    var.test_name
  )

  cidr = "10.10.0.0/16"

  azs           = ["us-west-1a", "us-west-1b", "us-west-1c"]
  intra_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
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

  vpc_subnet_ids         = module.vpc.intra_subnets
  vpc_security_group_ids = [module.vpc.default_security_group_id]

  function_description = "Function description."

  filename = data.archive_file.lambda_simple_zip_inline.output_path

  handler = "handler.lambda_handler"

  runtime = "python3.8"

  environment_variables = { Automation = "Terraform" }

  tags = var.tags
}

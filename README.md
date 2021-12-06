<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates an AWS Lambda Function.

```hcl
module "lambda_function" {
  source = "dod-iac/lambda-function/aws"

  execution_role_name = format(
    "app-%s-func-lambda-execution-role-%s",
    var.application,
    var.environment
  )

  function_name = format(
    "app-%s-func-%s-%s",
    var.application,
    var.environment,
    data.aws_region.current.name
  )

  function_description = "Function description."

  filename = format("../../lambda/%s-func.zip", var.application)

  handler = "index.handler"

  runtime = "nodejs12.x"

  environment_variables = var.environment_variables

  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

Use the optional `execution_role_policy_document` variable to override the IAM policy document for the IAM role.

Use the optional `cloudwatch_schedule_expression` variable to schedule execution of the Lambda using CloudWatch Events.

Use the optional `kms_key_arn` variable to encrypt the environment variables with a custom KMS key.  Use the `dod-iac/lambda-kms-key/aws` module to create a KMS key.

Use the optional `security_group_ids` and `subnet_ids` variable to run the function within a VPC.

## Testing

Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.

## Terraform Version

Terraform 0.12. Pin module version to ~> 1.0.1 . Submit pull-requests to master branch.

Terraform 0.11 is not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_rule_description"></a> [cloudwatch\_rule\_description](#input\_cloudwatch\_rule\_description) | The description of the CloudWatch Events rule used to schedule the execution of the Lambda. | `string` | `""` | no |
| <a name="input_cloudwatch_rule_name"></a> [cloudwatch\_rule\_name](#input\_cloudwatch\_rule\_name) | The name of the CloudWatch Events rule used to schedule the execution of the Lambda.  Defaults to the name of the Lambda function. | `string` | `""` | no |
| <a name="input_cloudwatch_schedule_expression"></a> [cloudwatch\_schedule\_expression](#input\_cloudwatch\_schedule\_expression) | The cron or rate expression for the CloudWatch Events rule that triggers the execution of the Lambda.  If blank, then no execution is scheduled. | `string` | `""` | no |
| <a name="input_cloudwatch_target_id"></a> [cloudwatch\_target\_id](#input\_cloudwatch\_target\_id) | The id of the CloudWatch Events target.  Defaults to the name of the Lambda function. | `string` | `""` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | A map that defines environment variables for the Lambda function. | `map(string)` | `{}` | no |
| <a name="input_event_sources"></a> [event\_sources](#input\_event\_sources) | A list of event sources | <pre>list(object({<br>    event_source_arn = string<br>  }))</pre> | `[]` | no |
| <a name="input_execution_role_name"></a> [execution\_role\_name](#input\_execution\_role\_name) | n/a | `string` | n/a | yes |
| <a name="input_execution_role_policy_document"></a> [execution\_role\_policy\_document](#input\_execution\_role\_policy\_document) | The contents of the IAM policy attached to the IAM Execution role used by the Lambda.  If not defined, then creates the policy with permissions to log to CloudWatch Logs. | `string` | `""` | no |
| <a name="input_execution_role_policy_name"></a> [execution\_role\_policy\_name](#input\_execution\_role\_policy\_name) | The name of the IAM policy attached to the IAM Execution role used by the Lambda.  If not defined, then uses the value of "execution\_role\_name". | `string` | `""` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | The path to the function's deployment package within the local filesystem.  If defined, the s3\_-prefixed options cannot be used. | `string` | n/a | yes |
| <a name="input_function_description"></a> [function\_description](#input\_function\_description) | Description of what your Lambda Function does. | `string` | `""` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | A unique name for your Lambda Function. | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | The function entrypoint in your code. | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of the KMS key used to encrypt environment variables. | `string` | `""` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. | `list(string)` | `[]` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB your Lambda Function can use at runtime. | `number` | `128` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The identifier of the function's runtime. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs associated with the Lambda function. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs associated with the Lambda function. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Lambda Function. | `map(string)` | <pre>{<br>  "Automation": "Terraform"<br>}</pre> | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The amount of time your Lambda Function has to run in seconds. | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_execution_role_arn"></a> [lambda\_execution\_role\_arn](#output\_lambda\_execution\_role\_arn) | The  Amazon Resource Name (ARN) identifying the IAM Role used to execute this Lambda. |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The Amazon Resource Name (ARN) identifying your Lambda Function. |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | A unique name for your Lambda Function. |
| <a name="output_lambda_function_qualified_arn"></a> [lambda\_function\_qualified\_arn](#output\_lambda\_function\_qualified\_arn) | The Amazon Resource Name (ARN) identifying your Lambda Function Version. |
| <a name="output_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#output\_lambda\_invoke\_arn) | The ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

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

## Terraform Version

Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 is not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.55.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch\_rule\_description | The description of the CloudWatch Events rule used to schedule the execution of the Lambda. | `string` | `""` | no |
| cloudwatch\_rule\_name | The name of the CloudWatch Events rule used to schedule the execution of the Lambda.  Defaults to the name of the Lambda function. | `string` | `""` | no |
| cloudwatch\_schedule\_expression | The cron or rate expression for the CloudWatch Events rule that triggers the execution of the Lambda.  If blank, then no execution is scheduled. | `string` | `""` | no |
| cloudwatch\_target\_id | The id of the CloudWatch Events target.  Defaults to the name of the Lambda function. | `string` | `""` | no |
| environment\_variables | A map that defines environment variables for the Lambda function. | `map(string)` | `{}` | no |
| execution\_role\_name | n/a | `string` | n/a | yes |
| execution\_role\_policy\_document | The contents of the IAM policy attached to the IAM Execution role used by the Lambda.  If not defined, then creates the policy with permissions to log to CloudWatch Logs. | `string` | `""` | no |
| execution\_role\_policy\_name | The name of the IAM policy attached to the IAM Execution role used by the Lambda.  If not defined, then uses the value of "execution\_role\_name". | `string` | `""` | no |
| filename | The path to the function's deployment package within the local filesystem.  If defined, the s3\_-prefixed options cannot be used. | `string` | n/a | yes |
| function\_description | Description of what your Lambda Function does. | `string` | `""` | no |
| function\_name | A unique name for your Lambda Function. | `string` | n/a | yes |
| handler | The function entrypoint in your code. | `string` | n/a | yes |
| layers | List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. | `list(string)` | `[]` | no |
| memory\_size | Amount of memory in MB your Lambda Function can use at runtime. | `number` | `128` | no |
| runtime | The identifier of the function's runtime. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the Lambda Function. | `map(string)` | <pre>{<br>  "Automation": "Terraform"<br>}</pre> | no |
| timeout | The amount of time your Lambda Function has to run in seconds. | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda\_execution\_role\_arn | The  Amazon Resource Name (ARN) identifying the IAM Role used to execute this Lambda. |
| lambda\_function\_arn | The Amazon Resource Name (ARN) identifying your Lambda Function. |
| lambda\_function\_name | A unique name for your Lambda Function. |
| lambda\_function\_qualified\_arn | The Amazon Resource Name (ARN) identifying your Lambda Function Version. |
| lambda\_invoke\_arn | The ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri. |


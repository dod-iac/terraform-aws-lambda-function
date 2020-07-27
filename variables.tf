variable "cloudwatch_rule_description" {
  type        = string
  description = "The description of the CloudWatch Events rule used to schedule the execution of the Lambda."
  default     = ""
}

variable "cloudwatch_rule_name" {
  type        = string
  description = "The name of the CloudWatch Events rule used to schedule the execution of the Lambda.  Defaults to the name of the Lambda function."
  default     = ""
}

variable "cloudwatch_schedule_expression" {
  type        = string
  description = "The cron or rate expression for the CloudWatch Events rule that triggers the execution of the Lambda.  If blank, then no execution is scheduled."
  default     = ""
}

variable "cloudwatch_target_id" {
  type        = string
  description = "The id of the CloudWatch Events target.  Defaults to the name of the Lambda function."
  default     = ""
}

variable "environment_variables" {
  type        = map(string)
  description = "A map that defines environment variables for the Lambda function."
  default     = {}
}

variable "execution_role_name" {
  type = string
}

variable "execution_role_policy_document" {
  type        = string
  description = "The contents of the IAM policy attached to the IAM Execution role used by the Lambda.  If not defined, then creates the policy with permissions to log to CloudWatch Logs."
  default     = ""
}

variable "execution_role_policy_name" {
  type        = string
  description = "The name of the IAM policy attached to the IAM Execution role used by the Lambda.  If not defined, then uses the value of \"execution_role_name\"."
  default     = ""
}

variable "filename" {
  type        = string
  description = "The path to the function's deployment package within the local filesystem.  If defined, the s3_-prefixed options cannot be used."
  default     = ""
}

variable "function_name" {
  type        = string
  description = "A unique name for your Lambda Function."
}

variable "function_description" {
  type        = string
  description = "Description of what your Lambda Function does."
  default     = ""
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
}

variable "layers" {
  type        = list(string)
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function."
  default     = []
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  default     = 128
}

variable "runtime" {
  type        = string
  description = "The identifier of the function's runtime."
}

variable "s3_bucket" {
  type        = string
  description = "The S3 bucket location containing the function's deployment package.  Conflicts with filename.  This bucket must reside in the same AWS region where you are creating the Lambda function."
  default     = ""
}

variable "s3_key" {
  type        = string
  description = "The S3 key of an object containing the function's deployment package.  Conflicts with filename."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Lambda Function."
  default = {
    Automation = "Terraform"
  }
}

variable "timeout" {
  type        = number
  description = "The amount of time your Lambda Function has to run in seconds."
  default     = 3
}

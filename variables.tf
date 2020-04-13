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

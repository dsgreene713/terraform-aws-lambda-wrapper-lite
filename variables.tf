######################################################################################
# required variables
######################################################################################
variable "function_name" {
  type        = string
  description = "A unique name for your Lambda Function"
}

variable "lambda_source_dir" {
  type        = string
  description = "source directory for function code"
}

variable "function_handler" {
  type        = string
  description = "Lambda Function entrypoint in your code"
}

variable "function_runtime" {
  type        = string
  description = "Lambda Function runtime"
}

######################################################################################
# optional variables
######################################################################################
variable "description" {
  type        = string
  description = "Description of what your Lambda Function does"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "map of tag(s) to assign to the function"
  default     = {}
}

variable "architectures" {
  type        = list(string)
  description = "Instruction set architecture for your Lambda function"
  default     = ["x86_64"]
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "tracing_mode" {
  description = "Tracing mode of the Lambda Function. Valid value can be either PassThrough or Active."
  type        = string
  default     = "Active"
}

variable "logging_log_format" {
  description = "The log format of the Lambda Function. Valid values are \"JSON\" or \"Text\"."
  type        = string
  default     = "Text"
}

variable "logging_application_log_level" {
  description = "The application log level of the Lambda Function. Valid values are \"TRACE\", \"DEBUG\", \"INFO\", \"WARN\", \"ERROR\", or \"FATAL\"."
  type        = string
  default     = "INFO"
}

variable "logging_system_log_level" {
  description = "The system log level of the Lambda Function. Valid values are \"DEBUG\", \"INFO\", or \"WARN\"."
  type        = string
  default     = "INFO"
}

variable "logging_log_group" {
  description = "The CloudWatch log group to send logs to."
  type        = string
  default     = null
}

variable "vpc_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}
variable "vpc_security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function."
  type        = list(string)
  default     = null
}

variable "kms_key_arn" {
  description = "The ARN of KMS key to use by your Lambda Function"
  type        = string
  default     = null
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version."
  type        = bool
  default     = false
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 120
}
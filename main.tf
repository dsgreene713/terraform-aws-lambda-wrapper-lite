data "aws_partition" "current" {}

locals {
  function_output_path = "${path.module}/${var.function_name}.zip"
}

######################################################################################
# iam
######################################################################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

######################################################################################
# lambda
######################################################################################
data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = local.function_output_path
}

resource "aws_lambda_function" "this" {
  # filename         = filebase64sha256(local.function_output_path)
  source_code_hash = data.archive_file.this.output_base64sha256
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  handler          = var.function_handler
  runtime          = var.function_runtime
  layers           = var.layers
  timeout          = var.timeout
  publish          = var.publish
  kms_key_arn      = var.kms_key_arn

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]

    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []

    content {
      security_group_ids = var.vpc_security_group_ids
      subnet_ids         = var.vpc_subnet_ids
    }
  }

  dynamic "logging_config" {
    for_each = data.aws_partition.current.partition == "aws" ? [true] : []

    content {
      log_group             = var.logging_log_group
      log_format            = var.logging_log_format
      application_log_level = var.logging_log_format == "Text" ? null : var.logging_application_log_level
      system_log_level      = var.logging_log_format == "Text" ? null : var.logging_system_log_level
    }
  }
}
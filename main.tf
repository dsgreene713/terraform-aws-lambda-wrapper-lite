data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }
}

data "aws_iam_policy_document" "merged" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.cloudwatch_logs.json],
    var.additional_json_policy_documents
  )
}

resource "aws_iam_policy" "merged" {
  name   = "${var.function_name}-policy"
  policy = data.aws_iam_policy_document.merged.json
}

resource "aws_iam_role" "this" {
  name                = "${var.function_name}-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [aws_iam_policy.merged.arn]
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
  filename         = local.function_output_path
  description      = var.description
  architectures    = var.architectures
  source_code_hash = data.archive_file.this.output_base64sha256
  function_name    = var.function_name
  role             = aws_iam_role.this.arn
  handler          = var.function_handler
  runtime          = var.function_runtime
  layers           = var.layers
  timeout          = var.timeout
  publish          = var.publish
  kms_key_arn      = var.kms_key_arn
  tags             = var.tags

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
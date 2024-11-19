locals {
  # Use the sns_topic_arn variable if set in tfvars; otherwise fallback to the created SNS topic
  resolved_sns_topic_arn = coalesce(
    var.sns_topic_arn,
    var.create_sns == "yes" && length(aws_sns_topic.sns_topic) > 0 ? aws_sns_topic.sns_topic[0].arn : null
  )
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../files/lambda_function.py"
  output_path = "${path.module}/security-hub/lambda_function.zip"
}

resource "aws_lambda_function" "security_hub_report" {
  function_name = "${var.cust_name}-security-hub-report-lambda-${var.report_regions}"
  role          = aws_iam_role.security_hub_lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 900
  memory_size   = 512

  environment {
    variables = {
      aws_account_1  = var.aws_account_1
      aws_account_2  = var.aws_account_2
      aws_account_3  = var.aws_account_3
      aws_account_4  = var.aws_account_4
      aws_account_5  = var.aws_account_5
      cust_name      = var.cust_name
      report_regions = var.report_regions
      out_bucket     = var.out_bucket
      web_hook_url   = var.web_hook_url
      sns_topic_arn  = local.resolved_sns_topic_arn
    }
  }

  filename = data.archive_file.lambda_zip.output_path
}

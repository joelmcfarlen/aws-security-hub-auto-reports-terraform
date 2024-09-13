resource "aws_lambda_function" "security_hub_report" {
  function_name = "${var.cust_name}-security-hub-report-lambda-${var.report_regions}"
  role          = aws_iam_role.security_hub_lambda_exec_role.arn  # Attach role from iam.tf
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 900
  memory_size   = 512

  environment {
    variables = {
      aws_account_1   = var.aws_account_1
      aws_account_2   = var.aws_account_2
      aws_account_3   = var.aws_account_3
      aws_account_4   = var.aws_account_4
      aws_account_5   = var.aws_account_5
      cust_name       = var.cust_name
      report_regions  = var.report_regions
      out_bucket      = var.out_bucket
      web_hook_url    = var.web_hook_url
    }
  }

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

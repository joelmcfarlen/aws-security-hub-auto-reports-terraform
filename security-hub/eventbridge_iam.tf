resource "aws_iam_role" "security_hub_eventbridge_scheduler_role" {
  name = "${var.cust_name}-security-hub-eventbridge-scheduler-role-${var.report_regions}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke_lambda_policy" {
  name = "${var.cust_name}-eventbridge-invoke-lambda-policy-${var.report_regions}"
  role = aws_iam_role.security_hub_eventbridge_scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          "arn:aws:lambda:${var.report_regions}:${var.master_account_number}:function:${var.cust_name}-security-hub-report-lambda-${var.report_regions}:*",
          "arn:aws:lambda:${var.report_regions}:${var.master_account_number}:function:${var.cust_name}-security-hub-report-lambda-${var.report_regions}"
        ]
      }
    ]
  })
}

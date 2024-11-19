resource "aws_iam_role" "security_hub_lambda_exec_role" {
  name = "${var.cust_name}-security-hub-lambda-exec-role-${var.report_regions}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_logs_policy" {
  name = "${var.cust_name}-lambda-logs-policy-${var.report_regions}"
  role = aws_iam_role.security_hub_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:${var.report_regions}:${var.master_account_number}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.report_regions}:${var.master_account_number}:log-group:/aws/lambda/${var.cust_name}-security-hub-report-lambda-${var.report_regions}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3_invoke_policy" {
  name = "${var.cust_name}-lambda-s3-invoke-policy-${var.report_regions}"
  role = aws_iam_role.security_hub_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:lambda:${var.report_regions}:${var.master_account_number}:function:${var.cust_name}-security-hub-report-lambda-${var.report_regions}",
          "arn:aws:s3:::${var.out_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "sns_access_policy" {
  name = "${var.cust_name}-sns-access-policy-${var.report_regions}"
  role = aws_iam_role.security_hub_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = "arn:aws:sns:${var.report_regions}:${var.master_account_number}:${var.cust_name}-security-hub-sns-topic"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "security_hub_readonly" {
  role       = aws_iam_role.security_hub_lambda_exec_role.id
  policy_arn = "arn:aws:iam::aws:policy/AWSSecurityHubReadOnlyAccess"
}

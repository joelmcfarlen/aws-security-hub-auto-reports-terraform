resource "aws_cloudwatch_event_rule" "security_hub_schedule" {
  name                = "${var.cust_name}-security-hub-report-schedule-${var.report_regions}"
  description         = "Scheduled rule to trigger the Security Hub report Lambda function"
  schedule_expression = var.report_schedule
}

resource "aws_cloudwatch_event_target" "trigger_security_hub_report" {
  rule      = aws_cloudwatch_event_rule.security_hub_schedule.name
  target_id = "${var.cust_name}-security-hub-report-lambda-${var.report_regions}"
  arn       = aws_lambda_function.security_hub_report.arn
}

resource "aws_lambda_permission" "allow_eventbridge_to_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.security_hub_report.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_hub_schedule.arn
}

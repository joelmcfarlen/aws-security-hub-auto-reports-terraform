
resource "aws_sns_topic" "sns_topic" {
  count = var.create_sns == "yes" ? 1 : 0
  name = "${var.cust_name}-security-hub-sns-topic"
}

locals {
  sns_topic_arn = var.create_sns == "yes" && length(aws_sns_topic.sns_topic) > 0 ? aws_sns_topic.sns_topic[0].arn : var.sns_topic_arn
}

output "sns_topic_arn" {
  value       = local.sns_topic_arn
  description = "The ARN of the SNS topic used for Security Hub notifications"
}

output "debug_sns_topic_count" {
  value       = length(aws_sns_topic.sns_topic)
  description = "The count of created SNS topics."
}

output "debug_sns_topic_arn" {
  value       = local.sns_topic_arn
  description = "The resolved SNS topic ARN."
}

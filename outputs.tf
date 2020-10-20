output "sns_topic_arn" {
  description = "The ARN of the SNS topic used"
  value       = local.sns_topic_arn
}

output "dashboard_combined" {
  description = "URL to CloudWatch Combined Metric Dashboard"
  value       = local.dashboard_combined_url
}

output "dashboard_individual" {
  description = "URL to CloudWatch Individual Metric Dashboard"
  value       = local.dashboard_main_individual_url
}

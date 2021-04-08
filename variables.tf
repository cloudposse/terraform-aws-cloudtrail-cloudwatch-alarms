variable "additional_endpoint_arns" {
  description = "Any alert endpoints, such as autoscaling, or app scaling endpoint arns that will respond to an alert"
  default     = []
  type        = list(string)
}

variable "sns_topic_arn" {
  description = "An SNS topic ARN that has already been created. Its policy must already allow access from CloudWatch Alarms, or set `add_sns_policy` to `true`"
  default     = null
  type        = string
}

variable "sns_policy_enabled" {
  description = "Attach a policy that allows the notifications through to the SNS topic endpoint"
  default     = false
  type        = bool
}

variable "log_group_region" {
  description = "The log group region that should be monitored for unauthorised AWS API Access. Current region used if none provided."
  default     = ""
  type        = string
}

variable "log_group_name" {
  description = "The cloudtrail cloudwatch log group name"
  type        = string
}

variable "metric_namespace" {
  description = "A namespace for grouping all of the metrics together"
  default     = "CISBenchmark"
  type        = string
}

variable "dashboard_enabled" {
  description = "When true a dashboard that displays the statistics as a line graph will be created in CloudWatch"
  default     = true
  type        = bool
}

variable "kms_master_key_id" {
  type        = string
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  default     = "alias/aws/sns"
}

variable "metrics" {
  type = map(object({
    metric_name               = string
    filter_pattern            = string
    metric_namespace          = string
    metric_value              = string
    alarm_name                = string
    alarm_comparison_operator = string
    alarm_evaluation_periods  = string
    alarm_period              = string
    alarm_statistic           = string
    alarm_treat_missing_data  = string
    alarm_threshold           = string
    alarm_description         = string
  }))
  default     = {}
  description = "The cloudwatch metrics and corresponding alarm definitions"
}

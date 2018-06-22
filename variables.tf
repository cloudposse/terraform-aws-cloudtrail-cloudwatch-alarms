variable "additional_endpoint_arns" {
  description = "Any alert endpoints, such as autoscaling, or app scaling endpoint arns that will respond to an alert"
  default     = []
  type        = "list"
}

variable "sns_topic_arn" {
  description = "An SNS topic ARN that has already been created. Its policy must already allow access from CloudWatch Alarms, or set `add_sns_policy` to `true`"
  default     = ""
  type        = "string"
}

variable "add_sns_policy" {
  description = "Attach a policy that allows the notifications through to the SNS topic endpoint"
  default     = "false"
  type        = "string"
}

variable "region" {
  description = "The region that should be monitored for unauthorised AWS API Access. Current region used if none provied."
  default     = ""
  type        = "string"
}

variable "access_denied_threshold" {
  description = "The threshold to alert on for denied access logs for AWS."
  type        = "string"
  default     = "1"
}

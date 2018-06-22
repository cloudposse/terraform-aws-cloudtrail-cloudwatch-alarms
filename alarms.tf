data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  thresholds = {
    AccessDeniedThreshold = "${max(var.access_denied_threshold, 0)}"
  }

  alert_for        = "AWS Access Denied"
  sns_topic_arn    = "${var.sns_topic_arn == "" ? aws_sns_topic.default.arn : var.sns_topic_arn }"
  endpoints        = "${distinct(compact(concat(list(local.sns_topic_arn), var.additional_endpoint_arns)))}"
  region           = "${var.region == "" ? data.aws_region.current.name : var.region}"
  log_group_name   = "${var.log_group_name}"
  metric_name      = "AWSAPIAccessDenied"
  metric_namespace = "CISBenchmark"
  metric_value     = "1"
  filter_pattern   = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
}

# "arn:aws:logs:$${aws_region}:$${account_id}:log-group:$${log_group_name}:*" 

# aws_cloudwatch_log_group..name

resource "aws_cloudwatch_log_metric_filter" "default" {
  name           = "${local.AWSAPIAccessDenied}-${local.log_group_name}"
  pattern        = "${local.filter_pattern}"
  log_group_name = "${local.log_group_name}"

  metric_transformation {
    name      = "${local.metric_name}"
    namespace = "${local.metric_namespace}"
    value     = "${local.metric_value}"
  }
}

resource "aws_cloudwatch_metric_alarm" "default" {
  alarm_name          = "${local.AWSAPIAccessDenied}-${local.log_group_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "${local.metric_namespace}"
  period              = "300"                                                            // 5 min
  statistic           = "Sum"
  threshold           = "${local.thresholds["AccessDeniedThreshold"]}"
  alarm_description   = "This metric tracks unauthorised access logs in ${local.region}"
  alarm_actions       = ["${local.endpoints}"]
}

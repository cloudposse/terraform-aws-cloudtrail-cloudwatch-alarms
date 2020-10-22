data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  alert_for        = "CloudTrailBreach"
  sns_topic_arn    = var.sns_topic_arn == "" && (length(aws_sns_topic.default) == 1 ? aws_sns_topic.default[0].arn : "") != "" ? aws_sns_topic.default[0].arn : var.sns_topic_arn
  endpoints        = distinct(compact(concat([local.sns_topic_arn], var.additional_endpoint_arns)))
  log_group_region = var.log_group_region == "" ? data.aws_region.current.name : var.log_group_region

  metric_namespace = var.metric_namespace
  metric_value     = "1"
}

resource "aws_cloudwatch_log_metric_filter" "default" {
  count          = module.this.enabled ? length(local.metrics) : 0
  name           = join(module.this.delimiter, [local.metrics[count.index].name, "filter"])
  pattern        = local.metrics[count.index].filter_pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name      = local.metrics[count.index].name
    namespace = local.metric_namespace
    value     = local.metric_value
  }
}

resource "aws_cloudwatch_metric_alarm" "default" {
  count               = module.this.enabled ? length(local.metrics) : 0
  alarm_name          = join(module.this.delimiter, [local.metriks[count.index].name, "alarm"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = local.metrics[count.index].name
  namespace           = local.metric_namespace
  // Period is in seconds (300 seconds == 5 mins)
  period             = "300"
  statistic          = "Sum"
  treat_missing_data = "notBreaching"
  threshold          = local.metrics[count.index].name == "ConsoleSignInFailureCount" ? "3" : "1"
  alarm_description  = local.metrics[count.index].description
  alarm_actions      = local.endpoints
  tags               = module.this.tags
}

resource "aws_cloudwatch_dashboard" "combined" {
  count          = module.this.enabled && var.create_dashboard == "true" ? 1 : 0
  dashboard_name = join(module.this.delimiter, ["cis", "benchmark", "statistics", "combined"])
  // https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html#CloudWatch-Dashboard-Properties-Metrics-Array-Format
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 20
        height = 16
        properties = {
          metrics = [
            for metric in local.metrics :
            [local.metric_namespace, metric.name]
          ]
          period = 300
          stat   = "Sum"
          region = local.log_group_region
          title  = "${local.metric_namespace} Statistics"
        }
      }
    ]
  })
}

locals {
  # Two Columns
  # Will experiment with this values
  layout_x = [0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12]
  layout_y = [0, 0, 7, 7, 15, 15, 22, 22, 29, 29, 36, 36, 43, 43, 50, 50]
}

resource "aws_cloudwatch_dashboard" "individual" {
  count          = module.this.enabled && var.create_dashboard == "true" ? 1 : 0
  dashboard_name = join(module.this.delimiter, ["cis", "benchmark", "statistics", "individual"])

  dashboard_body = jsonencode({
    widgets = [
      for index, metric in local.metrics :
      {
        type   = "metric"
        x      = local.layout_x[index]
        y      = local.layout_y[index]
        width  = 12
        height = 6
        properties = {
          metrics = [
            [local.metric_namespace, metric.name]
          ]
          period = 300
          stat   = "Sum"
          region = local.log_group_region
          title  = metric.name
        }
      }
    ]
  })
}

locals {
  dashboard_url_prefix = "https://console.aws.amazon.com/cloudwatch/home?region=${local.log_group_region}#dashboards:name="

  dashboard_combined_url   = join("", concat([local.dashboard_url_prefix], aws_cloudwatch_dashboard.combined.*.dashboard_name))
  dashboard_individual_url = join("", concat([local.dashboard_url_prefix], aws_cloudwatch_dashboard.individual.*.dashboard_name))
}

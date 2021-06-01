data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  alert_for             = "CloudTrailBreach"
  is_creating_sns_topic = var.sns_topic_arn == null && length(aws_sns_topic.default) == 1
  sns_topic_arn         = local.is_creating_sns_topic ? aws_sns_topic.default[0].arn : var.sns_topic_arn
  endpoints             = distinct(compact(concat([local.sns_topic_arn], var.additional_endpoint_arns)))
  log_group_region      = var.log_group_region == "" ? data.aws_region.current.name : var.log_group_region

  metric_namespace = var.metric_namespace
  metric_value     = "1"
  metrics_index    = values(var.metrics)
}

resource "aws_cloudwatch_log_metric_filter" "default" {
  for_each       = module.this.enabled ? var.metrics : {}
  name           = each.value.metric_name
  metric_name    = var.alarm_suffix != null ? join("-", tolist([each.value.metric_name, var.alarm_suffix])) : each.value.metric_name
  pattern        = each.value.filter_pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.metric_namespace
    value     = each.value.metric_value
  }
}

resource "aws_cloudwatch_metric_alarm" "default" {
  for_each            = module.this.enabled ? var.metrics : {}
  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.alarm_comparison_operator
  evaluation_periods  = each.value.alarm_evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.metric_namespace
  period              = each.value.alarm_period
  statistic           = each.value.alarm_statistic
  treat_missing_data  = each.value.alarm_treat_missing_data
  threshold           = each.value.alarm_threshold
  alarm_description   = each.value.alarm_description
  alarm_actions       = local.endpoints
  tags                = module.this.tags
}

resource "aws_cloudwatch_dashboard" "combined" {
  count          = module.this.enabled && var.dashboard_enabled ? 1 : 0
  dashboard_name = join(module.this.delimiter, ["cis", "benchmark", "statistics", "combined"])
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html#CloudWatch-Dashboard-Properties-Metrics-Array-Format
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
            for metric in var.metrics :
            [metric.metric_namespace, metric.metric_name]
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
  count          = module.this.enabled && var.dashboard_enabled ? 1 : 0
  dashboard_name = join(module.this.delimiter, ["cis", "benchmark", "statistics", "individual"])

  dashboard_body = jsonencode({
    widgets = [
      for index, metric in local.metrics_index :
      {
        type   = "metric"
        x      = local.layout_x[index]
        y      = local.layout_y[index]
        width  = 12
        height = 6
        properties = {
          metrics = [
            [metric.metric_namespace, metric.metric_name]
          ]
          period = 300
          stat   = "Sum"
          region = local.log_group_region
          title  = metric.metric_name
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

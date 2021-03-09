data "aws_caller_identity" "default" {}

resource "aws_sns_topic" "default" {
  count             = module.this.enabled ? 1 : 0
  name              = join(module.this.delimiter, [local.alert_for, "threshold", "alerts"])
  tags              = module.this.tags
  kms_master_key_id = var.kms_master_key_id
}

resource "aws_sns_topic_policy" "default" {
  count  = module.this.enabled != true && var.sns_policy_enabled != true && var.sns_topic_arn != "" ? 0 : 1
  arn    = local.sns_topic_arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = [local.sns_topic_arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "arn:aws:iam::${data.aws_caller_identity.default.account_id}:root",
      ]
    }
  }

  statement {
    sid       = "Allow ${local.alert_for} CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = [local.sns_topic_arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = local.metric_alarms_arns
    }
  }
}

locals {
  metric_alarms_arns = [for i in aws_cloudwatch_metric_alarm.default: i.arn]
}

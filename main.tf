data "aws_caller_identity" "default" {}

module "sns_kms_key_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  count   = local.create_kms_key ? 1 : 0

  attributes = ["sns"]
  context    = module.this.context
}

module "sns_kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"
  count   = local.create_kms_key ? 1 : 0

  name                = local.create_kms_key ? module.sns_kms_key_label[0].id : ""
  description         = "KMS key for the ${local.alert_for} SNS topic"
  enable_key_rotation = true
  alias               = "alias/${local.alert_for}-sns"
  policy              = local.create_kms_key ? data.aws_iam_policy_document.sns_kms_key_policy[0].json : ""

  context = module.this.context
}

data "aws_iam_policy_document" "sns_kms_key_policy" {
  count = local.create_kms_key ? 1 : 0

  policy_id = "CloudWatchEncryptUsingKey"

  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}

module "aws_sns_topic_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["cloudtrail-breach"]
  context    = module.this.context
}

resource "aws_sns_topic" "default" {
  count             = local.enabled ? 1 : 0
  name              = module.aws_sns_topic_label.id
  tags              = module.this.tags
  kms_master_key_id = local.create_kms_key ? module.sns_kms_key[0].key_id : var.kms_master_key_id
}

resource "aws_sns_topic_policy" "default" {
  count  = local.enabled == true && var.sns_policy_enabled == true ? 1 : 0
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
  enabled            = module.this.enabled
  create_kms_key     = local.enabled && var.kms_master_key_id == null
  metric_alarms_arns = [for i in aws_cloudwatch_metric_alarm.default : i.arn]
}

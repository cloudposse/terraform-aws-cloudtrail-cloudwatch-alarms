data "aws_caller_identity" "default" {}

# Make a topic
resource "aws_sns_topic" "default" {
  name_prefix = "${local.alert_for}-threshold-alerts"
}

resource "aws_sns_topic_policy" "default" {
  count  = "${var.add_sns_policy != "true" && var.sns_topic_arn != "" ? 0 : 1}"
  arn    = "${local.sns_topic_arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
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
    resources = ["${aws_sns_topic.default.arn}"]

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
    resources = ["${aws_sns_topic.default.arn}"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

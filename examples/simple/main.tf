### For connecting and provisioning
variable "region" {
  default = "us-east-1"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = "${var.region}"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

## This is the module being used
module "cloudtrail_api_alarms" {
  source         = "../../"
  region         = "${var.region}"
  log_group_name = "${aws_cloudwatch_log_group.default.name}"
}

## Everything after this is standard cloudtrail setup
resource "aws_s3_bucket" "default" {
  bucket_prefix = "cw-bucket-${var.region}"
  region        = "${var.region}"
}

resource "aws_s3_bucket_policy" "default" {
  bucket = "${aws_s3_bucket.default.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.default.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.default.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
}
EOF
}

resource "aws_iam_role" "cloudtrail_cloudwatch_events_role" {
  name_prefix        = "cloudtrail_events_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_policy.json}"
}

resource "aws_iam_role_policy" "policy" {
  name_prefix = "cloudtrail_cloudwatch_events_policy"
  role        = "${aws_iam_role.cloudtrail_cloudwatch_events_role.id}"
  policy      = "${data.aws_iam_policy_document.policy.json}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream"]
    resources = ["${aws_cloudwatch_log_group.default.arn}:*:log-stream:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.default.arn}:log-stream:*"]
  }
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name_prefix = "cloudtrail"
}

resource "aws_cloudtrail" "default" {
  name                          = "cloudtrail-${var.region}"
  enable_logging                = "true"
  s3_bucket_name                = "${aws_s3_bucket.default.id}"
  enable_log_file_validation    = "false"
  is_multi_region_trail         = "true"
  include_global_service_events = "true"
  cloud_watch_logs_role_arn     = "${aws_iam_role.cloudtrail_cloudwatch_events_role.arn}"
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.default.arn}"
  depends_on                    = ["aws_s3_bucket_policy.default"]
}

output "sns_topic_arn" {
  value = "${module.cloudtrail_api_alarms.sns_topic_arn}"
}

output "dashboard_individual" {
  value = "${module.cloudtrail_api_alarms.dashboard_individual}"
}

output "dashboard_combined" {
  value = "${module.cloudtrail_api_alarms.dashboard_combined}"
}

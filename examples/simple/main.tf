### For connecting and provisioning
variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.region}"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

resource "aws_s3_bucket" "default" {
  bucket_prefix = "cw-bucket-${var.region}"
}

module "cloudtail_api_denied_alarms" {
  source = "../../"
}

resource "aws_iam_role" "cloudtail_cloudwatch_events_role" {
  policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {

      "Sid": "AWSCloudTrailCreateLogStream2014110",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "arn:aws:logs:us-east-2:accountID:log-group:log_group_name:log-stream:CloudTrail_log_stream_name_prefix*"
      ]

    },
    {
      "Sid": "AWSCloudTrailPutLogEvents20141101",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:us-east-2:accountID:log-group:log_group_name:log-stream:CloudTrail_log_stream_name_prefix*"
      ]
    }
  ]
}
EOF
}

resource "aws_cloudtrail" "default" {
  name                          = "cloudtrail-${var.region}"
  enable_logging                = "trie"
  s3_bucket_name                = "${aws_s3_bucket.default.id}"
  enable_log_file_validation    = "false"
  is_multi_region_trail         = "true"
  include_global_service_events = "${var.include_global_service_events}"
  cloud_watch_logs_role_arn     = "${var.cloud_watch_logs_role_arn}"
  cloud_watch_logs_group_arn    = "${var.cloud_watch_logs_group_arn}"
  tags                          = "${module.cloudtrail_label.tags}"
  event_selector                = ["${var.event_selector}"]
  kms_key_id                    = "${var.kms_key_id}"
}

output "efs_alarms_sns_topic_arn" {
  value = "${module.cloudtail_api_denied_alarms.sns_topic_arn}"
}

# terraform-aws-cloudtrail-cloudwatch-alarms
Terraform module for creating alarms for tracking important changes and occurances from cloudtrail.

This module creates a set of filter metrics and alarms based on the security best practices covered in the AWS guide [AWS_CIS_Foundations_Benchmark](https://d0.awsstatic.com/whitepapers/compliance/AWS_CIS_Foundations_Benchmark.pdf).

## Usage
```hcl
module "cloudtrail_api_alarms" {
  source         = "git::https://github.com/cloudposse/terraform-aws-cloudtrail-cloudwatch-alarms.git"
  region         = "${var.region}"
  log_group_name = "${aws_cloudwatch_log_group.default.name}"
}
```
For detailed usage which includes setting up cloudtrail, cloudwatch logs, roles, policies, and the s3 bucket - as well as using this module see the [example directory](./examples/simple)
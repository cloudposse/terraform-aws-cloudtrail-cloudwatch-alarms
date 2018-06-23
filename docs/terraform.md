
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add_sns_policy | Attach a policy that allows the notifications through to the SNS topic endpoint | string | `false` | no |
| additional_endpoint_arns | Any alert endpoints, such as autoscaling, or app scaling endpoint arns that will respond to an alert | list | `<list>` | no |
| create_dashboard | When true a dashboard that displays tha statistics as a line graph will be created in CloudWatch | string | `true` | no |
| log_group_name | The cloudtrail cloudwatch log group name | string | - | yes |
| metric_namespace | A namespace for grouping all of the metrics together | string | `CISBenchmark` | no |
| region | The region that should be monitored for unauthorised AWS API Access. Current region used if none provied. | string | `` | no |
| sns_topic_arn | An SNS topic ARN that has already been created. Its policy must already allow access from CloudWatch Alarms, or set `add_sns_policy` to `true` | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| dashboard_combined | URL to CloudWatch Combined Metric Dashboard |
| dashboard_individual | URL to CloudWatch Individual Metric Dashboard |
| sns_topic_arn | The ARN of the SNS topic used |


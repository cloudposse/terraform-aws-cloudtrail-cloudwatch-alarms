data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  alert_for     = "CloudTrailBreach"
  sns_topic_arn = var.sns_topic_arn == "" ? aws_sns_topic.default.arn : var.sns_topic_arn
  endpoints     = distinct(compact(concat([local.sns_topic_arn], var.additional_endpoint_arns)))
  log_group_region        = var.log_group_region == "" ? data.aws_region.current.name : var.log_group_region

  metric_name = [
    "AuthorizationFailureCount",
    "S3BucketActivityEventCount",
    "SecurityGroupEventCount",
    "NetworkAclEventCount",
    "GatewayEventCount",
    "VpcEventCount",
    "EC2InstanceEventCount",
    "EC2LargeInstanceEventCount",
    "CloudTrailEventCount",
    "ConsoleSignInFailureCount",
    "IAMPolicyEventCount",
    "ConsoleSignInWithoutMfaCount",
    "RootAccountUsageCount",
    "KMSKeyPendingDeletionErrorCount",
    "AWSConfigChangeCount",
    "RouteTableChangesCount",
  ]

  metric_namespace = var.metric_namespace
  metric_value     = "1"

  filter_pattern = [
    "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }",
    "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }",
    "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup) }",
    "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }",
    "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }",
    "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }",
    "{ ($.eventName = RunInstances) || ($.eventName = RebootInstances) || ($.eventName = StartInstances) || ($.eventName = StopInstances) || ($.eventName = TerminateInstances) }",
    "{ ($.eventName = RunInstances) && (($.requestParameters.instanceType = *.8xlarge) || ($.requestParameters.instanceType = *.4xlarge) || ($.requestParameters.instanceType = *.16xlarge) || ($.requestParameters.instanceType = *.10xlarge) || ($.requestParameters.instanceType = *.12xlarge) || ($.requestParameters.instanceType = *.24xlarge)) }",
    "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }",
    "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }",
    "{ ($.eventName = DeleteGroupPolicy) || ($.eventName = DeleteRolePolicy) ||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}",
    "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") }",
    "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }",
    "{($.eventSource = kms.amazonaws.com) && (($.eventName=DisableKey)||($.eventName=ScheduleKeyDeletion))}",
    "{($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder))}",
    "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }",
  ]

  alarm_description = [
    "Alarms when an unauthorized API call is made.",
    "Alarms when an API call is made to S3 to put or delete a Bucket, Bucket Policy or Bucket ACL.",
    "Alarms when an API call is made to create, update or delete a Security Group.",
    "Alarms when an API call is made to create, update or delete a Network ACL.",
    "Alarms when an API call is made to create, update or delete a Customer or Internet Gateway.",
    "Alarms when an API call is made to create, update or delete a VPC, VPC peering connection or VPC connection to classic.",
    "Alarms when an API call is made to create, terminate, start, stop or reboot an EC2 instance.",
    "Alarms when an API call is made to create, terminate, start, stop or reboot a 4x-large or greater EC2 instance.",
    "Alarms when an API call is made to create, update or delete a .cloudtrail. trail, or to start or stop logging to a trail.",
    "Alarms when an unauthenticated API call is made to sign into the console.",
    "Alarms when an API call is made to change an IAM policy.",
    "Alarms when a user logs into the console without MFA.",
    "Alarms when a root account usage is detected.",
    "Alarms when a customer created KMS key is pending deletion.",
    "Alarms when AWS Config changes.",
    "Alarms when route table changes are detected.",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "default" {
  count          = module.this.enabled ? length(local.filter_pattern) : 0
  name           = join(module.this.delimiter, [module.this.id, local.metric_name[count.index], "filter"])
  pattern        = local.filter_pattern[count.index]
  log_group_name = var.log_group_name

  metric_transformation {
    name      = local.metric_name[count.index]
    namespace = local.metric_namespace
    value     = local.metric_value
  }
}

resource "aws_cloudwatch_metric_alarm" "default" {
  count               = module.this.enabled ? length(local.filter_pattern) : 0
  alarm_name = join(module.this.delimiter, [module.this.id, local.metric_name[count.index], "alarm"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = local.metric_name[count.index]
  namespace           = local.metric_namespace
  period              = "300"                                                                         // 5 min
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  threshold           = local.metric_name[count.index] == "ConsoleSignInFailureCount" ? "3" :"1"
  alarm_description   = local.alarm_description[count.index]
  alarm_actions       = local.endpoints
  tags = module.this.tags
}

resource "aws_cloudwatch_dashboard" "main" {
  count          = module.this.enabled && var.create_dashboard == "true" ? 1 : 0
  dashboard_name = join(module.this.delimiter, [module.this.id, "cis", "benchmark", "statistics", "combined"])

  dashboard_body = <<EOF
 {
   "widgets": [
       {
          "type":"metric",
          "x":0,
          "y":0,
          "width":20,
          "height":16,
          "properties":{
             "metrics":[
               ${join(",",formatlist("[ \"${local.metric_namespace}\", \"%v\" ]", local.metric_name))}
             ],
             "period":300,
             "stat":"Sum",
             "region":"${local.log_group_region}",
             "title":"CISBenchmark Statistics"
          }
       }
   ]
 }
 EOF
}

locals {
  # Two Columns
  # Will experiment with this values
  layout_x = [0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12, 0, 12]

  layout_y = [0, 0, 7, 7, 15, 15, 22, 22, 29, 29, 36, 36, 43, 43, 50, 50]
}

resource "aws_cloudwatch_dashboard" "main_individual" {
  count          = module.this.enabled && var.create_dashboard == "true" ? 1 : 0
  dashboard_name = join(module.this.delimiter, [module.this.id, "cis", "benchmark", "statistics", "individual"])

  dashboard_body = <<EOF
 {
   "widgets": [
     ${join(",",formatlist(
       "{
          \"type\":\"metric\",
          \"x\":%v,
          \"y\":%v,
          \"width\":12,
          \"height\":6,
          \"properties\":{
             \"metrics\":[
                [ \"${local.metric_namespace}\", \"%v\" ]
            ],
          \"period\":300,
          \"stat\":\"Sum\",
          \"region\":\"${local.log_group_region}\",
          \"title\":\"%v\"
          }
       }
       ", local.layout_x, local.layout_y, local.metric_name, local.metric_name))}
   ]
 }
 EOF
}

locals {
  dashboard_url_prefix = "https://console.aws.amazon.com/cloudwatch/home?region=${var.log_group_region}#dashboards:name="

  dashboard_combined_url = join("", concat([local.dashboard_url_prefix], aws_cloudwatch_dashboard.main.*.dashboard_name))
  dashboard_main_individual_url = join("", concat([local.dashboard_url_prefix], aws_cloudwatch_dashboard.main_individual.*.dashboard_name))
}

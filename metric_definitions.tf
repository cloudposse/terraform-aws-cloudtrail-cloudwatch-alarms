locals {
  metrics = [
    {
      name: "AuthorizationFailureCount",
      filter_pattern: "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }",
      description: "Alarms when an unauthorized API call is made.",
    },
    {
      name: "S3BucketActivityEventCount",
      filter_pattern: "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }",
      description: "Alarms when an API call is made to S3 to put or delete a Bucket, Bucket Policy or Bucket ACL.",
    },
    {
      name: "SecurityGroupEventCount",
      filter_pattern: "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup) }",
      description: "Alarms when an API call is made to create, update or delete a Security Group.",
    },
    {
      name: "NetworkAclEventCount",
      filter_pattern: "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }",
      description: "Alarms when an API call is made to create, update or delete a Network ACL.",
    },
    {
      name: "GatewayEventCount",
      filter_pattern: "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }",
      description: "Alarms when an API call is made to create, update or delete a Customer or Internet Gateway.",
    },
    {
      name: "VpcEventCount",
      filter_pattern: "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }",
      description: "Alarms when an API call is made to create, update or delete a VPC, VPC peering connection or VPC connection to classic.",
    },
    {
      name: "EC2InstanceEventCount",
      filter_pattern:"{ ($.eventName = RunInstances) || ($.eventName = RebootInstances) || ($.eventName = StartInstances) || ($.eventName = StopInstances) || ($.eventName = TerminateInstances) }",
      description: "Alarms when an API call is made to create, terminate, start, stop or reboot an EC2 instance.",
    },
    {
      name: "EC2LargeInstanceEventCount",
      filter_pattern: "{ ($.eventName = RunInstances) && (($.requestParameters.instanceType = *.8xlarge) || ($.requestParameters.instanceType = *.4xlarge) || ($.requestParameters.instanceType = *.16xlarge) || ($.requestParameters.instanceType = *.10xlarge) || ($.requestParameters.instanceType = *.12xlarge) || ($.requestParameters.instanceType = *.24xlarge)) }",
      description: "Alarms when an API call is made to create, terminate, start, stop or reboot a 4x-large or greater EC2 instance.",
    },
    {
      name: "CloudTrailEventCount",
      filter_pattern: "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }",
      description: "Alarms when an API call is made to create, update or delete a .cloudtrail. trail, or to start or stop logging to a trail.",
    },
    {
      name: "ConsoleSignInFailureCount",
      filter_pattern: "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }",
      description: "Alarms when an unauthenticated API call is made to sign into the console.",
    },
    {
      name: "IAMPolicyEventCount",
      filter_pattern: "{ ($.eventName = DeleteGroupPolicy) || ($.eventName = DeleteRolePolicy) ||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}",
      description: "Alarms when an API call is made to change an IAM policy.",
    },
    {
      name: "ConsoleSignInWithoutMfaCount",
      filter_pattern: "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") }"
      description: "Alarms when a user logs into the console without MFA.",
    },
    {
      name: "RootAccountUsageCount",
      filter_pattern: "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }",
      description: "Alarms when a root account usage is detected.",
    },
    {
      name: "KMSKeyPendingDeletionErrorCount",
      filter_pattern: "{($.eventSource = kms.amazonaws.com) && (($.eventName=DisableKey)||($.eventName=ScheduleKeyDeletion))}",
      description: "Alarms when a customer created KMS key is pending deletion.",
    },
    {
      name: "AWSConfigChangeCount",
      filter_pattern: "{($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder))}",
      description: "Alarms when AWS Config changes.",
    },
    {
      name: "RouteTableChangesCount",
      filter_pattern: "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }",
      description: "Alarms when route table changes are detected.",
    },
  ]
}

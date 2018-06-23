# terraform-aws-cloudtrail-cloudwatch-alarms
Terraform module for creating alarms for tracking important changes and occurances from cloudtrail.

This module creates a set of filter metrics and alarms based on the security best practices covered in the AWS guide [AWS_CIS_Foundations_Benchmark](https://d0.awsstatic.com/whitepapers/compliance/AWS_CIS_Foundations_Benchmark.pdf).

|  Alarm's Name |  Description  |
|:-------------:|:-------------:|
|  AuthorizationFailureCount    |  Alarms when an unauthorized API call is made.  | 
|  S3BucketActivityEventCount   |  Alarms when an API call is made to S3 to put or delete a Bucket, Bucket Policy or Bucket ACL.  | 
|  SecurityGroupEventCount      |  Alarms when an API call is made to create, update or delete a Security Group.  | 
|  NetworkAclEventCount         |  Alarms when an API call is made to create, update or delete a Network ACL.  | 
|  GatewayEventCount            |  Alarms when an API call is made to create, update or delete a Customer or Internet Gateway.  | 
|  VpcEventCount                |  Alarms when an API call is made to create, update or delete a VPC, VPC peering connection or VPC connection to classic.  | 
|  EC2InstanceEventCount        |  Alarms when an API call is made to create, terminate, start, stop or reboot an EC2 instance.  | 
|  EC2LargeInstanceEventCount   |  Alarms when an API call is made to create, terminate, start, stop or reboot a 4x-large or greater EC2 instance.  | 
|  CloudTrailEventCount         |  Alarms when an API call is made to create, update or delete a .cloudtrail. trail, or to start or stop logging to a trail.  | 
|  ConsoleSignInFailureCount    |  Alarms when an unauthenticated API call is made to sign into the console.  | 
|  IAMPolicyEventCount          |  Alarms when an API call is made to change an IAM policy.   |

## Usage
```hcl
module "cloudtrail_api_alarms" {
  source         = "git::https://github.com/cloudposse/terraform-aws-cloudtrail-cloudwatch-alarms.git"
  region         = "${var.region}"
  log_group_name = "${aws_cloudwatch_log_group.default.name}"
}
```
For detailed usage which includes setting up cloudtrail, cloudwatch logs, roles, policies, and the s3 bucket - as well as using this module see the [example directory](./examples/simple)


### From LICENSE
>  The alarm metric names, descriptions, and filters from this repository were used
>  https://github.com/TeliaSoneraNorge/telia-terraform-modules/tree/master/cloudtrail-forwarder
>  With many thanks to Anton https://github.com/antonbabenko for pointing it out and saving
>  me a lot of time scouring reference documents and describing alarms!

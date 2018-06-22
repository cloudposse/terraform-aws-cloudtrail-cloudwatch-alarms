# terraform-aws-unauthorised-api-cloudwatch-alarms
Terraform module for creating alarms for tracking AccessDenied and UnAuthorisedAccess results from AWS api via cloudtrail.

>  This alert may be triggered by normal read-only console activities that attempt to
>  opportunistically gather optional information, but gracefully fail if they don't have
>  permissions.
>  If an excessive number of alerts are being generated then an organization may wish to
>  consider adding read access to the limited IAM user permissions simply to quiet the alerts.
>  In some cases doing this may allow the users to actually view some areas of the system -
>  any additional access given should be reviewed for alignment with the original limited IAM
>  user intent.

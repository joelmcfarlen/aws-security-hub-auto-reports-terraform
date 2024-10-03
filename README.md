Welcome to the Automated AWS Security Hub Reporting Solution

SUMMARY:
This module is used to deploy an automated Security Hub Reporting Solution and its supporting infrastructure in an AWS Master account. Natively, it can genetrate a report for up to 5 AWS accounts which is then outputted to a cental S3 bucket (typically in the "logging" account) on a monthly basis. Once the report is generated it will send a notification with report/location details to a webhook (Teams/Slack/ect). It contains the following:

1) Lambda function used to generate and push the Security Hub Report to S3
2) Lambda IAM execution role
3) EventBridge Schedule
4) Event Bridge IAM execution role
5) Supporting raw documents

DEPLOYMENT NOTES:
- The required centralized S3 bucket will need to be configured with the bucket policy found in the "files" directory. Replace "MASTER_ACCOUNT_NUMBER", "CUST_NAME","REPORT_REGIONS", and "S3_BUCKET" with the needed information
- AWS Org and AWS Config will need to be in place in the Master account
- Adjust the "report_schedule" variable to the needed cadence
- Input "n/a" as the value for any "aws_account_X" that are not needed
- Solution is region specific so you will need a tfvars file per region
- You will need to enable all Security Hub Standards (i.e. CIS, NIST, ect) in the target accounts you wish to include in the findings report

NOTE: Keep in mind that Security Hub Stanards when first enabled typically take a few hours to gather data. Also, MS Teams webhooks are EOL very soon (Dec 2025). This portion will eventual be adjusted as needed.


DEPLOYMENT COMMANDS:

- Enter the below commands in the "security-hub" directory to plan/deploy the solution. Update the tfvars file name as needed:

$ terraform plan -var-file=hubbsters.tfvars

$ terraform apply -var-file=hubbsters.tfvars
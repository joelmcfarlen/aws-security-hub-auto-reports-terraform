
// REPORTING ACCOUNTS (use "n/a" as a value if not needed)
master_account_number  = ""
aws_account_1          = ""
aws_account_2          = ""
aws_account_3          = ""
aws_account_4          = ""
aws_account_5          = ""


// REPORTING ACCOUNT NAME
cust_name              = ""


// REPORTING AWS REGION
report_regions         = ""


// S3 BUCKET TO PUT REPORT
out_bucket             = ""


 // WEBHOOK URL
 web_hook_url          = ""


  // SNS TOPIC ARN (ADD ARN ONLY IF MANUALLY CONFIGURING AN SNS TOPIC IN A SEPERATE AWS ACCOUNT)
 sns_topic_arn         = ""


 // USE SNS SWITCH
 create_sns               = ""


 // REPORTING SCHEDULE (UPDATE AS NEEDED)
 report_schedule       = "cron(0 2 1 * ? *)"
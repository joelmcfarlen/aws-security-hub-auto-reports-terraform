

// REPORTING ACCOUNTS
variable "master_account_number" {
  description = "Master AWS Account Number"
  type        = string
}

variable "aws_account_1" {
   description = "AWS ACCOUNT TO REPORT"
   type        = string
 }

 variable "aws_account_2" {
   description = "AWS ACCOUNT TO REPORT"
   type        = string
 }

 variable "aws_account_3" {
   description = "AWS ACCOUNT TO REPORT"
   type        = string
 }

  variable "aws_account_4" {
   description = "AWS ACCOUNT TO REPORT"
   type        = string
 }

  variable "aws_account_5" {
   description = "AWS ACCOUNT TO REPORT"
   type        = string
 }


// REPORTING ACCOUNT NAME
 variable "cust_name" {
   description = "CUSTOMER NAME"
   type        = string
 }


// REPORTING AWS REGION
 variable "report_regions" {
   description = "AWS REPORTING REGIONS"
   type        = string
 }


// S3 BUCKET TO PUT REPORT
 variable "out_bucket" {
   description = "AWS S3 BUCKET FOR REPORT"
   type        = string
 }


 // TEAMS WEBHOOK URL
 variable "web_hook_url" {
   description = "MS TEAMS WEBHOOK URL"
   type        = string
 }


 // REPORTING SCHEDULE
 variable "report_schedule" {
   description = "REPORT GENERATION SCHEDULE IN CRON"
   type        = string
 }
 

 


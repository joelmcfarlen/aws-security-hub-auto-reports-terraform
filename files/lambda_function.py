import json
import sys
import os
import subprocess
import datetime
import boto3

# pip install custom package to /tmp/ and add to path
subprocess.call('pip install openpyxl pymsteams pandas -t /tmp/ --no-cache-dir'.split(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
sys.path.insert(1, '/tmp/')

import pandas as pd
import pymsteams
from openpyxl import Workbook
from openpyxl import load_workbook
from openpyxl.styles import Font
ft = Font(bold=True)

regions = os.environ['report_regions'].split(',')
out_bucket = os.environ['out_bucket']
webhookArray = os.environ['web_hook_url'].split(',')
cust_name = os.environ['cust_name']
aws_account_ids = [
    os.environ.get('aws_account_1', 'n/a'),
    os.environ.get('aws_account_2', 'n/a'),
    os.environ.get('aws_account_3', 'n/a'),
    os.environ.get('aws_account_4', 'n/a'),
    os.environ.get('aws_account_5', 'n/a')
]

today = datetime.date.today()
curr_day = today.strftime('%d')
curr_month = today.strftime('%m')
curr_year = today.strftime('%Y')

marker = None

def lambda_handler(event, context):
    # Append the first region value to the workbook name
    region_identifier = regions[0] if regions else "default-region"
    workbook_name = f"{cust_name}_Security_Hub_Findings_{region_identifier}.xlsx"
    
    headers_row = ['CustomerName', 'Region', 'AccountId', 'Title', 'ProductName', 'StandardsArn', 'Severity', 'ResourceType', 'ResourceId']

    try:
        workbook = load_workbook(filename=f"/tmp/{workbook_name}")
        if cust_name in workbook.sheetnames:
            worksheet = workbook[cust_name]
        else:
            workbook.create_sheet(cust_name)
            worksheet = workbook[cust_name]
            worksheet.append(headers_row)
    except FileNotFoundError:
        print(f"File not found. Creating one.")
        workbook = Workbook()
        worksheet = workbook.active
        worksheet.title = cust_name
        worksheet.append(headers_row)

    for region in regions:
        print(region)
        try:
            sh_client = boto3.client('securityhub', region)
            paginator = sh_client.get_paginator('get_findings')
            
            # Create the filters for each valid account
            account_filters = [
                {
                    'Value': account_id,
                    'Comparison': 'EQUALS'
                }
                for account_id in aws_account_ids if account_id != 'n/a'
            ]

            page_iterator = paginator.paginate(
                Filters={
                    'AwsAccountId': account_filters,
                    'ComplianceStatus': [
                        {
                            'Value': 'FAILED',
                            'Comparison': 'EQUALS'
                        },
                    ],
                    'GeneratorId': [
                        {
                            'Value': f"aws-foundational-security-best-practices/v/1.0.0/",
                            'Comparison': 'PREFIX'
                        },
                        {
                            'Value': f"cis-aws-foundations-benchmark/v/1.4.0",
                            'Comparison': 'PREFIX'
                        }
                    ],
                },
                PaginationConfig={
                    'PageSize': 50,
                    'StartingToken': marker
                }
            )
            for page in page_iterator:
                Findings = page['Findings']
                for finding in Findings:
                    try:
                        ProductName = finding['ProductName']
                        AwsAccountId = finding['AwsAccountId']
                        Title = finding['Title']
                        Severity = finding['Severity']['Label']
                        StandardsArn = finding['ProductFields'].get('StandardsArn', '')
                        Resources = finding['Resources']
                        WorkflowStatus = str(finding['Workflow'].get('Status', ''))
                        WorkflowState = finding['WorkflowState']
                        RecordState = finding['RecordState']
                        for resource in Resources:
                            if WorkflowStatus == 'NEW' and RecordState == 'ACTIVE' and WorkflowState == 'NEW':
                                Type = resource['Type']
                                Id = resource['Id']
                                new_row = [cust_name, region, AwsAccountId, Title, ProductName, StandardsArn, Severity, Type, Id]
                                worksheet.append(new_row)
                    except Exception as e:
                        print(e)

            df = pd.DataFrame(worksheet.values)
            df.columns = df.iloc[0]
            df = df[1:]
            df = df.sort_values(by='AccountId', ascending=False)
            worksheet.delete_rows(2, worksheet.max_row)
            for index, row in df.iterrows():
                worksheet.append(row.tolist())

            worksheet.auto_filter.ref = worksheet.dimensions
            workbook.save(f"/tmp/{workbook_name}")

            try:
                print('uploading file to s3')
                s3_client = boto3.client('s3')
                s3_response = s3_client.upload_file(
                    f"/tmp/{workbook_name}",
                    out_bucket,
                    f"SecurityHubReports/{curr_year}/{curr_month}/{curr_day}/{workbook_name}",
                    ExtraArgs={
                        'ACL': 'bucket-owner-full-control'
                    }
                )
            except Exception as e:
                print(e)

            try:
                msg_text = f"Security Hub Report for {cust_name} is ready in the S3 bucket {out_bucket} in your logging account. You can access it via the console or using the cli command '$ aws s3 s3://{out_bucket}/{curr_year}/{curr_month}/{curr_day}/{workbook_name}' when authenticated to your logging account"
                for url in webhookArray:
                    print(f"Sending message to {url}")
                    myTeamsMessage = pymsteams.connectorcard(url)
                    myTeamsMessage.title("Security Report Notification")
                    myTeamsMessage.color("0000FF")
                    myTeamsMessage.text(msg_text)
                    myTeamsMessage.send()
            
            except Exception as e:
                print(e)

        except Exception as e:
            print(e)

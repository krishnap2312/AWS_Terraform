import boto3
import datetime
import pytz

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    # The security group ID and the VPC ID should be passed through event or environment variables
    security_group_id = 'sg-xxxxxx'  # Replace with the actual Security Group ID
    
    # Define the time zone for IST (Indian Standard Time)
    timezone = pytz.timezone('Asia/Kolkata')  # IST is UTC +5:30

    # Get the current time in IST
    current_time = datetime.datetime.now(timezone).hour
    
    # Log the current time for debugging (Optional)
    print(f"Current time in IST: {current_time} hours")

    if 9 <= current_time < 17:
        # Between 9 AM and 5 PM: Allow traffic on HTTP (80) and HTTPS (443)
        ingress_rules = [
            {
                'IpProtocol': 'tcp',
                'FromPort': 80,
                'ToPort': 80,
                'CidrIp': '0.0.0.0/0'
            },
            {
                'IpProtocol': 'tcp',
                'FromPort': 443,
                'ToPort': 443,
                'CidrIp': '0.0.0.0/0'
            }
        ]
        # Authorize security group ingress (allow traffic)
        ec2.authorize_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=ingress_rules
        )
    else:
        # Outside 9 AM to 5 PM: Remove the rules (deny traffic)
        ingress_rules = [
            {
                'IpProtocol': 'tcp',
                'FromPort': 80,
                'ToPort': 80,
                'CidrIp': '0.0.0.0/0'
            },
            {
                'IpProtocol': 'tcp',
                'FromPort': 443,
                'ToPort': 443,
                'CidrIp': '0.0.0.0/0'
            }
        ]
        # Revoke security group ingress (deny traffic)
        ec2.revoke_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=ingress_rules
        )

    return {
        'statusCode': 200,
        'body': 'Security group updated successfully'
    }

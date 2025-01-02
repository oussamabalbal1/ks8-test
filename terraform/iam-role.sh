#!/bin/bash

# Define variables
ROLE_NAME="ADMIN-ROLE-K8S"
INSTANCE_ID="i-0997a50f5e475e540"
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess" # Or appropriate managed policy

# 1. Create the IAM Role
echo "Creating IAM Role: $ROLE_NAME"
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "$TRUST_POLICY" \
    --description "Role for AWS Load Balancer Controller"

# Get the Role ARN
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)
echo "Role ARN: $ROLE_ARN"

# 2. Attach the AWSLoadBalancerControllerFullAccess Policy to the Role
echo "Attaching policy: $POLICY_ARN to role: $ROLE_NAME"
aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "$POLICY_ARN"

# 3. Create an Instance Profile (required for EC2)
echo "Creating Instance Profile"
aws iam create-instance-profile --instance-profile-name "$ROLE_NAME"

# 4. Add the Role to the Instance Profile
echo "Adding role $ROLE_NAME to Instance Profile $ROLE_NAME"
aws iam add-role-to-instance-profile \
    --instance-profile-name "$ROLE_NAME" \
    --role-name "$ROLE_NAME"

# 5. Associate the Instance Profile with the EC2 Instance
echo "Associating Instance Profile with EC2 Instance: $INSTANCE_ID"
aws ec2 associate-iam-instance-profile \
    --instance-id "$INSTANCE_ID" \
    --iam-instance-profile Name="$ROLE_NAME"

echo "IAM Role creation and association complete."
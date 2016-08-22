#!/usr/bin/env bash

echo "Creating a new security group: SaltCloudInstances"
aws ec2 create-security-group \
    --group-name SaltCloudInstances \
    --description "The Security Group applied to all salt-cloud instances"

echo "Opening port 22 to public for: SaltCloudInstances"
aws ec2 authorize-security-group-ingress \
    --group-name SaltCloudInstances \
    --protocol tcp --port 22 \
    --cidr 0.0.0.0/0

echo "Allowing all ports inside SaltCloudInstances security group:"
aws ec2 authorize-security-group-ingress \
    --group-name SaltCloudInstances \
    --source-group SaltCloudInstances \
    --protocol all --port 0-65535

# Get group ID and Subnet ID
export SG_ID=$(aws ec2 describe-security-groups --group-name SaltCloudInstances| jq .SecurityGroups[].GroupId)
export SUBNET_ID=$(aws ec2 describe-subnets --filters Name=availabilityZone,Values=${AWS_DEFAULT_AZ} | jq .Subnets[].SubnetId)

echo "Updating /etc/salt/cloud.providers.d/aws.conf and /etc/salt/cloud.profiles.d/ubuntu_ec2.conf:"
sed "
s|AWS_KEY|${AWS_ACCESS_KEY_ID}|g
s|AWS_SECRET|${AWS_SECRET_ACCESS_KEY}|g
s|AWS_REGION|${AWS_DEFAULT_REGION}|g
s|AWS_AZ|${AWS_DEFAULT_AZ}|g" \
-i /etc/salt/cloud.providers.d/aws.conf
sed "
s|SG_ID|${SG_ID}|g
s|SUBNET_ID|${SUBNET_ID}|g
s|AMI_ID|${AWS_AMI_ID}|g" \
-i /etc/salt/cloud.profiles.d/ubuntu_ec2.conf

echo "Generating new pem key: /etc/salt/salt_cloud_key.pem"
ssh-keygen -f /etc/salt/salt_cloud_key.pem -t rsa -b 4096 -q -N ""
chmod 400 /etc/salt/salt_cloud_key.pem

echo "Importing pub key to AWS with name: salt_cloud_key"
salt-cloud -f import_keypair ec2 keyname=salt_cloud_key file=/etc/salt/salt_cloud_key.pem.pub

echo "All done!"


#!/bin/bash
regions=("us-east-1" "us-west-2" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" "ap-northeast-1" "eu-central-1" "ca-central-1" "eu-west-1" "eu-west-2")

for region in "${regions[@]}"
do
  echo "Processing region: ${region}"
  BUCKET_NAME="tioth-chatgpt-plugin-resources-${region}"
  aws s3api put-bucket-acl --bucket $BUCKET_NAME --acl public-read
  OBJECTS=$(aws s3api list-objects --bucket $BUCKET_NAME --output json | jq -r '.Contents[].Key')
  for OBJECT in $OBJECTS
    do
      aws s3api put-object-acl --bucket $BUCKET_NAME --key $OBJECT --acl public-read
    done
  echo "Public-read permissions granted to all objects in $BUCKET_NAME"
done

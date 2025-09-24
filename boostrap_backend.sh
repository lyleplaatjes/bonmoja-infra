#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
AWS_REGION="eu-west-1"          # Change to your preferred region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="bonmoja-terraform-state-${ACCOUNT_ID}"
DYNAMO_TABLE="terraform-locks"

echo "Bootstrapping Terraform backend in region $AWS_REGION for account $ACCOUNT_ID"

# 1. Create S3 bucket (if it doesn’t exist)
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "✅ S3 bucket $BUCKET_NAME already exists"
else
  echo "⏳ Creating S3 bucket: $BUCKET_NAME"
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
  echo "✅ S3 bucket created"
fi

# Enable versioning (best practice for TF state)
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled
echo "✅ Versioning enabled on $BUCKET_NAME"

# 2. Create DynamoDB table (if it doesn’t exist)
if aws dynamodb describe-table --table-name "$DYNAMO_TABLE" >/dev/null 2>&1; then
  echo "✅ DynamoDB table $DYNAMO_TABLE already exists"
else
  echo "⏳ Creating DynamoDB table: $DYNAMO_TABLE"
  aws dynamodb create-table \
    --table-name "$DYNAMO_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region "$AWS_REGION"
  echo "✅ DynamoDB table created"
fi

echo "🎉 Backend bootstrap complete"
echo "Use these values in your backend.tf:"
echo ""
echo "bucket         = \"$BUCKET_NAME\""
echo "dynamodb_table = \"$DYNAMO_TABLE\""
echo "region         = \"$AWS_REGION\""

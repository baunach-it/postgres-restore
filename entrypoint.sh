#!/bin/bash
export AWS_ACCESS_KEY_ID=$POSTGRES_RESTORE_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$POSTGRES_RESTORE_AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$POSTGRES_RESTORE_AWS_DEFAULT_REGION

POSTGRES_RESTORE_TARGET_DB_HOST=$POSTGRES_RESTORE_TARGET_DB_HOST
POSTGRES_RESTORE_TARGET_DB_PORT=$POSTGRES_RESTORE_TARGET_DB_PORT
POSTGRES_RESTORE_TARGET_USER=$POSTGRES_RESTORE_TARGET_USER
POSTGRES_RESTORE_TARGET_PASSWORD=$POSTGRES_RESTORE_TARGET_PASSWORD
POSTGRES_RESTORE_TARGET_DB_NAME=$POSTGRES_RESTORE_TARGET_DB_NAME
POSTGRES_RESTORE_AWS_S3_BUCKET=$POSTGRES_RESTORE_AWS_S3_BUCKET
POSTGRES_RESTORE_AWS_S3_PATH=$POSTGRES_RESTORE_AWS_S3_PATH
DUMPFILE=$POSTGRES_RESTORE_DUMPFILE
CLI_VERSION_ARG=""

if [ -z "$DUMPFILE" ]; then
  echo "Usage: missing ENV POSTGRES_RESTORE_DUMPFILE <dumpfile>"
  exit 1
fi

if [ -n "$POSTGRES_RESTORE_AWS_CLI_VERSION" ]; then
  CLI_VERSION_ARG="-${POSTGRES_RESTORE_AWS_CLI_VERSION}"
  echo "AWS CLI version argument set to: $CLI_VERSION_ARG"
else
  echo "POSTGRES_RESTORE_AWS_CLI_VERSION is not set, will use the latest one."
fi

# Install AWS CLI only if not installed and POSTGRES_RESTORE_AWS_S3_* environment variables are set
if ! command -v aws &> /dev/null && [ -n "$POSTGRES_RESTORE_AWS_S3_BUCKET" ] && [ -n "$POSTGRES_RESTORE_AWS_S3_PATH" ]; then
  echo "AWS CLI not found and POSTGRES_RESTORE_AWS_S3_* variables are set. Installing AWS CLI..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64${CLI_VERSION_ARG}.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf awscliv2.zip aws
  echo "AWS CLI installed."
  aws --version
else
  echo "AWS CLI is already installed or POSTGRES_RESTORE_AWS_S3_* variables are not set."
fi

if [ -n "$POSTGRES_RESTORE_AWS_S3_BUCKET" ] && [ -n "$POSTGRES_RESTORE_AWS_S3_PATH" ]; then
  ENDPOINT_ARG=""
  if [ -n "$POSTGRES_RESTORE_S3_ENDPOINT" ]; then
    ENDPOINT_ARG="--endpoint-url $POSTGRES_RESTORE_S3_ENDPOINT"
    echo "Using custom S3 endpoint: $POSTGRES_RESTORE_S3_ENDPOINT"
  fi

  echo "Downloading dump file from S3: s3://$POSTGRES_RESTORE_AWS_S3_BUCKET/$POSTGRES_RESTORE_AWS_S3_PATH/$DUMPFILE"
  aws s3 cp "s3://$POSTGRES_RESTORE_AWS_S3_BUCKET/$POSTGRES_RESTORE_AWS_S3_PATH/$DUMPFILE" "/restore/$DUMPFILE" $ENDPOINT_ARG
  if [ $? -ne 0 ]; then
    echo "Failed to download dump file from S3"
    exit 1
  fi
fi

if [ -f "/restore/$DUMPFILE" ]; then
  echo "Found dump file locally: /restore/$DUMPFILE"
else
  echo "Dump file not found locally"
  exit 1
fi

# Restore the dump using psql
echo "Restoring dump file: /restore/$DUMPFILE"
gzip -c "/restore/$DUMPFILE" | PGPASSWORD=$POSTGRES_RESTORE_TARGET_PASSWORD psql -h $POSTGRES_RESTORE_TARGET_DB_HOST -p $POSTGRES_RESTORE_TARGET_DB_PORT -U $POSTGRES_RESTORE_TARGET_USER -d $POSTGRES_RESTORE_TARGET_DB_NAME

if [ $? -eq 0 ]; then
  echo "Database successfully restored from dump file: /restore/$DUMPFILE"
else
  echo "Failed to restore database from dump file."
  exit 1
fi
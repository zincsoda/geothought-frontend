#!/usr/bin/env bash

npm run build

if [ -z "${AWS_CLI_PROFILE}" ]; then
    aws_cli_profile=""
else
    aws_cli_profile="--profile ${AWS_CLI_PROFILE}"
fi

s3_deploy_bucket="geothought-site"
aws s3 cp index.html s3://${s3_deploy_bucket}/index.html\
    ${aws_cli_profile} --acl public-read \
    && echo "Successful Upload" || (echo "Failed" && exit 1)

aws s3 cp dist s3://${s3_deploy_bucket}/dist\
    ${aws_cli_profile} --recursive --acl public-read \
    && echo "Successful Upload" || (echo "Failed" && exit 1)


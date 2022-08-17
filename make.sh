#!/usr/bin/env bash

for i in "$@"; do
  case $i in
    -p=*|--prefix=*)
      PREFIX="${i#*=}"
      shift # past argument=value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

REGION="us-west-2"

set -x

echo "Create Deployment Stack: $PREFIX-deploy"
aws --region $REGION \
    cloudformation deploy \
    --template-file "deploy/deployment-s3.yaml" \
    --stack-name "$PREFIX-deploy"  \
    --parameter-overrides Prefix="$PREFIX"

echo "Packaging Component Infrastructure"
aws --region $REGION \
    cloudformation package \
    --template-file infra/component.yaml \
    --output-template packaged.yaml \
    --s3-bucket "$PREFIX-deployment-s3"

echo "Creating Component Infrastructure"
aws --region $REGION \
    cloudformation deploy \
    --template-file packaged.yaml \
    --stack-name "$PREFIX-challenge"  \
    --parameter-overrides Prefix="$PREFIX"


set +x

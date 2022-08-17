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

set +x

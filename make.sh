#!/usr/bin/env bash

BUILD_S3=false
PACKAGE=false
DEPLOY=false

for i in "$@"; do
  case $i in
    -p=*|--prefix=*)
      PREFIX="${i#*=}"
      shift # past argument=value
      ;;
    -S|--S3)
      BUILD_S3=true
      shift # past argument=value
      ;;
    -P|--package)
      PACKAGE=true
      shift # past argument=value
      ;;
    -D|--deploy)
      DEPLOY=true
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

if [ "$BUILD_S3" = "true" ] ; then
  echo "Create Deployment Stack: $PREFIX-deploy"
  aws --region $REGION \
      cloudformation deploy \
      --template-file "deploy/deployment-s3.yaml" \
      --stack-name "$PREFIX-deploy"  \
      --parameter-overrides Prefix="$PREFIX"
fi

if [ "$PACKAGE" = "true" ] ; then
  echo "Packaging Component Infrastructure"
  aws --region $REGION \
      cloudformation package \
      --template-file infra/component.yaml \
      --output-template packaged.yaml \
      --s3-bucket "$PREFIX-deployment-s3"
fi

if [ "$DEPLOY" = "true" ] ; then
  echo "Creating Component Infrastructure"
  aws --region $REGION \
      cloudformation deploy \
      --template-file packaged.yaml \
      --stack-name "$PREFIX-challenge"  \
      --parameter-overrides Prefix="$PREFIX"
fi

set +x

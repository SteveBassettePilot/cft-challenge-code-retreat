#!/usr/bin/env bash

PREFIX=
BUILD_S3=false
PACKAGE=false
DEPLOY=false

for i in "$@"; do
  case $i in
    -p=*|--prefix=*)
      PREFIX="${i#*=}"
      shift # past argument=value
      ;;
    -C|--complete)
      BUILD_S3=true
      PACKAGE=true
      DEPLOY=true
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
    -h|--help)
      echo "This app is part of a challenge to create a working CFT Structure"
      echo ""
      echo "USAGE:"
      echo "  ./make.sh -p=<team-name> [OPTIONS]"
      echo ""
      echo "OPTIONS:"
      echo "  -p|--prefix"
      echo "      REQUIRED"
      echo "      The team name prefix to be used for all CFTs"
      echo "  "
      echo "  -C|--complete"
      echo "      Run all steps of the challenge deployment"
      echo "      Functions the same as passing the -S -P -D options together"
      echo "  "
      echo "  -S|--S3"
      echo "      Create an S3 Bucket to stage the team's deployment items to"
      echo "  "
      echo "  -P|--package"
      echo "      Package the Component infrastructure and stage them for deploy"
      echo "  "
      echo "  -D|--deploy"
      echo "      Deploy the Component to AWS and build the stacks"
      exit 1
      ;;
    -*|--*)
      echo "Unknown option $i"
      echo "Try the -h option for help"
      exit 1
      ;;
    *)
      ;;
  esac
done

if [ "$PREFIX" = "" ] ; then
  echo "Prefix is required"
  echo "Try the -h option for help"
  exit 1
fi


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

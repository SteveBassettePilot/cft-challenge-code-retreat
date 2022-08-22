aws s3 cp sqs.yaml s3://test-earth-bucket/earth/earth-dev-infra-yaml-files/sqs.yaml --region us-west-2
aws s3 cp s3.yaml s3://test-earth-bucket/earth/earth-dev-infra-yaml-files/s3.yaml --region us-west-2
aws s3 cp Lambda.yaml s3://test-earth-bucket/earth/earth-dev-infra-yaml-files/Lambda.yaml --region us-west-2
aws s3 cp secretsmanager.yaml s3://test-earth-bucket/earth/earth-dev-infra-yaml-files/secretsmanager.yaml --region us-west-2

aws cloudformation validate-template --template-body file://Lambda.yaml 
aws cloudformation validate-template --template-body file://sqs.yaml 
aws cloudformation validate-template --template-body file://s3.yaml
aws cloudformation validate-template --template-body file://secretsmanager.yaml  
aws cloudformation validate-template --template-body file://infra-main.yaml 

aws cloudformation  create-stack  --stack-name  team-atlantic --template-body file://infra-main.yaml --parameters file://pap_dev_params.json --capabilities CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name team-atlantic $STACK_ID_FROM_CREATE_STACK
aws cloudformation describe-stacks --stack-name team-atlantic
# example-serverless-internet-gateway
Example of deploying a lambda behind an internet gateway with an elastic IP. Credit to @darvein for help with the CF template.

## VPC with NAT and an EIP

This will deploy via Cloud Formation:
* 1 VPC
* 1 Public Subnet and associated routes
* 1 Private Subnet and associated routes
* 1 NAT Gateway
* 1 Internet Gateway
* 1 Elastic IP Address

There is a terraform version as well, but because it does not use Cloud Formation, the outputs cannot be directly referenced from `serverless.yml`.

### Create the stack
```
AWS_ACCESS_KEY_ID="xxx" AWS_SECRET_ACCESS_KEY="yyy" aws --region us-east-1 cloudformation create-stack \
	--stack-name serverless-internet-gateway \
	--template-body file://esig-vpc.json \
	--parameters ParameterKey=Project,ParameterValue=serverless-internet-gateway \
	ParameterKey=Environment,ParameterValue=dev \
	ParameterKey=VpcCIDR,ParameterValue="10.0.0.0/16" \
	ParameterKey=PublicSubnet1Param,ParameterValue="10.0.0.0/24" \
	ParameterKey=PrivateSubnet1Param,ParameterValue="10.0.1.0/24"
```

## Lambda + API Gateway
The serverless.yml references the VPC stack for security group and subnet.

### Deploy
```
AWS_ACCESS_KEY_ID=xxx AWS_SECRET_ACCESS_KEY="yyy" node_modules/.bin/serverless deploy
```

To test, `curl` the endpoint and it should respond with the same IP as your NAT Gateway.

#!/bin/bash -x 

#  THIS SCRIPT CREATES THE KOPS CLUSTER

export AWS_ACCESS_KEY_ID=<ACCESS KEY >
export AWS_SECRET_ACCESS_KEY=<SECRET ACCESS KEY>

# KOPS CLUSTER STATE
export NAME=<CLUSTER NAME>
export KOPS_STATE_STORE=s3://<S3 BUCKET NAME>

kops create  cluster  ${NAME} --node-count 3  --zones us-east-1c, us-east-1b, us-east-1 --node-size t3.medium --master-size m5.large --master-zones us-east-1c,us-east-1b,us-east-1  --yes


 # Validate the cluster set as the current context of the kube config.
 # Uncomment the line below so that Kops tries for 10 minutes to validate the cluster 3 times.
#kops validate cluster --wait 10m --count 3

# Export kubeconfig 
kops export kubecfg --admin
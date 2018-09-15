#!/bin/bash
    
    NAME=$1
    
    [ -z "$NAME" ] && echo "NAME ARGUMENT not filled" && exit 1
    
    VPCID='<VPCID>'  #vpc-08669f89456f0780b
    
    INTERNALSUBNETID='<PrivateSubnet1AID>'  #subnet-0d69689899103420c
    
    EXTERNALSUBNETID1='<PublicSubnet1ID>'  #subnet-03d51c545098e37f7
    
    EXTERNALSUBNETID2='<PublicSubnet2ID>'  #subnet-08a1c3de0878c399b
    
    ### IAM section is for lab attendees
    
    #echo -e "\n######### Creating IAM User for $NAME.. ##########"
    
    ### Note: Create Group that has RO for VPC/CW/WAF/EC2. FullAccess for CF. IAM ChangePass.Name Group
    
    ### GroupName: EdgeServiceLab
    
    #aws iam create-user --user-name $NAME
    
    #aws iam add-user-to-group --group-name EdgeServiceLab --user-name $NAME 
    
    #aws iam create-login-profile --user-name $NAME --password qwertymnbvc --password-reset-required
    
    echo -e "\n######### Creating Environment for $NAME.. ##########"
    
    echo -e "\nCreating SG for ALB..."
    
    SGIDALB=`aws ec2 create-security-group --description "EdgeServiceLab-ALB-$NAME" --group-name "EdgeServiceLab-ALB-$NAME" --vpc-id $VPCID --output text`
    
    echo -e "\nLaunched SG for ALB - $SGIDALB..."
    
    aws ec2 create-tags --resources $SGIDALB --tags Key=Name,Value=$NAME-ALB
    
    aws ec2 authorize-security-group-ingress --group-id $SGIDALB  --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=' [{CidrIp=0.0.0.0/0}]'
    
    ### SG associated to EC2
    
    echo -e "\nCreating SG for EC2"
    
    SGIDEC2=`aws ec2 create-security-group --description "EdgeServiceLab-EC2-$NAME" --group-name "EdgeServiceLab-EC2-$NAME" --vpc-id $VPCID --output text`
    
    echo -e "\nLaunched SG for EC2 - $SGIDEC2..."
    
    aws ec2 create-tags --resources $SGIDEC2 --tags Key=Name,Value=$NAME-EC2
    
    aws ec2 authorize-security-group-ingress --group-id $SGIDEC2  --ip-permissions IpProtocol=tcp,FromPort=8080,ToPort=8080,UserIdGroupPairs=" [{GroupId=$SGIDALB,UserId=\"123456789012\"}]"
    
    aws ec2 authorize-security-group-ingress --group-id $SGIDEC2  --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,UserIdGroupPairs=" [{GroupId=$SGIDALB,UserId=\"123456789013\"}]"
    
    ### Create EC2 – AMI specified has been pre-configured with WebGoat
    
    echo -e "\nLaunching WebGoat EC2...."
    
    EC2OUTPUT=`aws ec2 run-instances --image-id ami-0da69443d6d7e455b --count 1 --instance-type t2.large --key-name $NAME  --security-group-ids $SGIDEC2 --subnet-id $INTERNALSUBNETID --output text` ;
    
    EC2ID=`echo $EC2OUTPUT | awk -F' ' '{print $9}'`
    
    aws ec2 create-tags --resources $EC2ID --tags Key=Name,Value=$NAME-EC2
    
    echo -e "\nLaunched EC2 - $EC2ID..."
    
    ### Create ALB
    
    echo -e "\nLaunching WebGoat ALB...."
    
    ALBOUTPUT=`aws elbv2 create-load-balancer --name $NAME-ALB --subnets $EXTERNALSUBNETID1 $EXTERNALSUBNETID2 --security-groups $SGIDALB --output text`
    
    ALBID=`echo $ALBOUTPUT | awk -F' ' '{print $6}'`
    
    ### Create Target Group
    
    echo -e "\nLaunching WebGoat ALB Target Group...."
    
    TGOUTPUT=`aws elbv2 create-target-group --name $NAME-target-ALB --protocol HTTP --port 80 --target-type instance --vpc-id $VPCID \
    --health-check-protocol HTTP --health-check-port 80 --health-check-path "/" --health-check-interval-seconds 5 --health-check-timeout-seconds 4 \
    --healthy-threshold-count 2 --unhealthy-threshold-count 2 --output text`
    
    TGID=`echo $TGOUTPUT | awk -F' ' '{print $10}'`
    
    aws elbv2 add-tags --resource-arns $TGID --tags "Key=Name,Value=$NAME-TG"
    
    echo -e "\nLaunched TargetGroup - $TGID...."
    
    sleep 20 ### why sleep? EC2 must be in running state before it can be registered
    
    echo -e "\nRegistering Targets to Target Group - $TGID...."
    
    aws elbv2 register-targets --target-group-arn $TGID --targets Id=$EC2ID,Port=8080
    
    ### Create Listener
    
    echo -e "\nLaunching WebGoat ALB Listener....."
    
    aws elbv2 create-listener --load-balancer-arn $ALBID --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$TGID --output text
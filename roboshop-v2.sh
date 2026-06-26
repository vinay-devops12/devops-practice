#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z008852933HNZNSM0V91L"
DOMAIN_NAME="daws-90s.shop"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d-%H:%M:%S")

## validation ##

if [ $# -lt 2 ]; then
  
  echo -e "$R ERROR:: At least two agreements required $N "

  echo "usage :$0 [create/delete] [instance1] [instance2]..."

   exit 1
fi

    ACTION=$1
     shift # first agrrement will be remove

if 
   [ "$ACTION" != "create" ] && [ "$ACTION" != "delete" ]; then

     echo -e "$R ERROR :: first aggrement must be either create or delete $N"
      echo "USAGE: $0 [create/delete] [instance1] [instance2..] "
          exit 1
fi





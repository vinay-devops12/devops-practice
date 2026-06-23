
#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$(basename $0).log"

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d-%H:%M:%S")

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R YOU SHOULD BE RUN AS ROOT USER $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $R $2...FAILED $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $G $2...SUCCESS $N" | tee -a $LOGS_FILE
    fi
}
cp $(dirname $0)/mango.repo /etc/yum.repos.d/mango.repo &>> $LOGS_FILE
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
 VALIDATE $? "installing mangodb"

 systemctl enable mongod &>>$LOGS_FILE
 VALIDATE $? "enable mangodb" 

 systemctl start mongod &>>$LOGS_FILE
  VALIDATE $? "starting mongodb"

  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
  VALIDATE $? "Allowing remote connection to mongodb"

  systemctl restart mongod  &>>$LOGS_FILE
  VALIDATE $? "Restarting mongodb"
  
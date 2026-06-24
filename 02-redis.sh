
#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"

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

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "disabling default redis module"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "enabling redis:7 module"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "installing redis:7"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "allowing remote connections"

sed -i '/protected-mode/c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "disabling protected mode"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "enabling redis"

systemctl start redis
VALIDATE $? "starting redis"
            
#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
    SCRIPT_DIR=$PWD

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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "installing nodejs"

#  Idempotent useradd
id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "creating user"
else
    echo -e "$TIMESTAMP [INFO] $G roboshop user already exists $N" | tee -a $LOGS_FILE
fi

mkdir -p /app &>>$LOGS_FILE
VALIDATE $? "creating directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading user code"

cd /app
unzip -o /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "extracted user code"

npm install &>>$LOGS_FILE
VALIDATE $? "installing the dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "copying user.service"
 
 
dnf install mongodb-mongosh -y
VALIDATE $? "Installed MongoDB client"

INDEX=$(mongosh --host mongodb.daws-90s.shop --eval 'db.getMongo().getDBNames().indexOf("user")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.daws-90s.shop < /app/db/master-data.js
    VALIDATE $? "load products"
else
    echo -e "products already loaded ....$Y SKIPPING $N"
fi

systemctl enable user &>>$LOGS_FILE
VALIDATE $? "enable user"

systemctl restart user &>>$LOGS_FILE
VALIDATE $? "Restarting user"

systemctl daemon-reload
VALIDATE $? "Load the service"


systemctl enable user 
VALIDATE $? "user"

systemctl start user
VALIDATE $? "user"




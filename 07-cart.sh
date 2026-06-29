            
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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading cart code"

cd /app
unzip -o /tmp/cart.zip &>>$LOGS_FILE
VALIDATE $? "extracted cart code"

npm install &>>$LOGS_FILE
VALIDATE $? "installing the dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/user.service
VALIDATE $? "cart.service"
 
systemctl enable cart&>>$LOGS_FILE
VALIDATE $? "enable cart"

systemctl restart user &>>$LOGS_FILE
VALIDATE $? "Restarting cart"

systemctl daemon-reload
VALIDATE $? "Load the service"


systemctl enable user 
VALIDATE $? "cart"

systemctl start user
VALIDATE $? "cart"




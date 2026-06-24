
#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0log"
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

    #  Idempotent useradd
id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "creating user"
else
    echo -e "$TIMESTAMP [INFO] $G roboshop user already exists $N" | tee -a $LOGS_FILE
fi


 
       cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOGS_FILE
        VALIDATE $? "adding rabbitmq repo"

        
            dnf install rabbitmq-server -y &>>$LOGS_FILE
            VALIDATE $? "installing rabbitmq server"


             systemctl enable rabbitmq-server &>>$LOGS_FILE
               VALIDATE $? "enable rabbitmq server"

             systemctl start rabbitmq-server &>>$LOGS_FILE
              VALIDATE $? "start rabbitmq server"

             rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
              VALIDATE $? "creating user" 
              
              rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>$LOGS_FILE
               VALIDATE $? "setting permissions"
#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
# MONGDB_HOST=mongodb.daws76s.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling nodejs Default version"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs:18 version \n Installing nodejs 18 version"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Nodejs Installed"

useradd roboshop &>> $LOGFILE

VALIDATE $? "Roboshop user added"

mkdir -p /app &>> $LOGFILE

VALIDATE $? "App directory created"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "catalog.zip file downloaded"

cd /app &>> $LOGFILE

VALIDATE $? "changed to app directory"

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping the catalogue.zip file in app dir"

npm install &>> $LOGFILE

VALIDATE $? "dependencies Installed"

cp /home/centos/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copied catalogue.service to server"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "mongo.repo copied to server"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "install mongodb-org-shell"

mongo --host mongodb.njkdr.online </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Pushing the data to catalogue from mongodb"

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
mkdir -p /app &>> $LOGFILE
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
cd /app &>> $LOGFILE
unzip /tmp/catalogue.zip &>> $LOGFILE
npm install &>> $LOGFILE

cp catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
systemctl daemon-reload &>> $LOGFILE
systemctl enable catalogue &>> $LOGFILE
systemctl start catalogue &>> $LOGFILE

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
dnf install mongodb-org-shell -y &>> $LOGFILE

mongo --host mongodb.njkdr.online </app/schema/catalogue.js &>> $LOGFILE

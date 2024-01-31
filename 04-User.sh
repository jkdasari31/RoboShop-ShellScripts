#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .... $R FAILED $N"
        exit 1
    else
        echo -e "$2 .... $R SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root User"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "Disabling nodejs default version"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "Enabling nodejs 18 version"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing nodejs 18 version"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE

VALIDATE $? "App directory created"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? "Zip file downloaded"

cd /app &>>$LOGFILE

VALIDATE $? "changed to app directory" 

unzip /tmp/user.zip &>>$LOGFILE

VALIDATE $? "Unzipping the user.zip " 

npm install &>>$LOGFILE

VALIDATE $? "Dependencies installed"

cp /home/centos/RoboShop-ShellScripts/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "Copied user.service to server /etc/systemd/system "

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Daemon reloaded"

systemctl enable user &>>$LOGFILE

VALIDATE $? "Enabled USER "

systemctl start user &>>$LOGFILE

VALIDATE $? "Stared User service"

cp /home/centos/RoboShop-ShellScripts/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copied mongo.repo to server"

dnf install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongodb-org-shell"

mongo --host mongodb.njkdr.online </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Pushing the USER data to schema"
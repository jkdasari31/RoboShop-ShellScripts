#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

exec &>>$LOGFILE

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

dnf module disable nodejs -y

VALIDATE $? "Disabling nodejs default version"

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling nodejs 18 version"

dnf install nodejs -y

VALIDATE $? "Installing nodejs 18 version"

useradd roboshop

VALIDATE $? "Roboshop user added"

mkdir -p /app

VALIDATE $? "App directory created"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip

VALIDATE $? "Zip file downloaded"

cd /app 

unzip /tmp/cart.zip

VALIDATE $? "Unzipping the cart.zip "

npm install 

VALIDATE $? "Dependencies installed"

cp cart.service /etc/systemd/system/cart.service

VALIDATE $? "Copied cart.service to server /etc/systemd/system "

systemctl daemon-reload

VALIDATE $? "Daemon reloaded"

systemctl enable cart 

VALIDATE $? "Enabled cart "

systemctl start cart

VALIDATE $? "Stared cart service"
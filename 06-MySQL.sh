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
        echo -e "$2 .... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root User"
fi # fi means reverse of if, indicating condition end

dnf module disable mysql -y

VALIDATE $? "Disabling default mysql version"

cp /home/centos/RoboShop-ShellScripts/mysql.repo /etc/yum.repos.d/mysql.repo

VALIDATE $? "Coping mysql.repo to server"

dnf install mysql-community-server -y

VALIDATE $? "Installing  MySQL"

systemctl enable mysqld

VALIDATE $? "Enabling  MySQL"

systemctl start mysqld

VALIDATE $? "Starting  MySQL"

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "Setting  MySQL root password"
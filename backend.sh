#!/bin/bash
logs_folder="/var/log/expense"
script_name=$(echo $0 | cut -d "." -f1)
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file="$logs_folder/$script_name-$timestamp.log"
mkdir -p $logs_folder
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run this script with root privileges $N" | tee -a $log_file
        exit 1
    fi
}
validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is...$G SUCCESS $N" | tee -a $log_file
    fi
}
echo "Script started executing at: $(date)" | tee -a $log_file
check_root
dnf module disable nodejs -y &>>$log_file
validate $? "disable default nodejs"
dnf module enable nodejs:20 -y &>>$log_file
validate $? "Enable nodejs:20"
dnf install nodejs -y &>>$log_file
validate $? "Install nodejs"
id expense &>>$log_file
if [ $? -ne 0 ]
then
    echo -e "expense user not exists...$G Creating $N"
    useradd expense &>>$log_file
    validate $? "Creating Expense user"
else
    echo -e "expense user already exists...$Y skipping $N"
fi
mkdir -p /app
validate $? "Creating /app folder"
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$log_file
validate $? "Downloading backend application code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$log_file
validate $? "Extracting backend application code"

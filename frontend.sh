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

dnf install nginx -y &>>$log_file
validate $? "Installing nginx"

systemctl enable nginx &>>$log_file
validate $? "Enable nginx"

systemctl start nginx &>>$log_file
validate $? "Start nginx"

rm -rf /usr/share/nginx/html/* &>>$log_file
validate $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$log_file
validate $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$log_file
validate $? "Extract frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
validate $? "Copied expense conf"

systemctl restart nginx


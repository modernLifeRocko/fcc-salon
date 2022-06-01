#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"
echo -e "\n~~~ My Salon: Appointment Booking System ~~~\n"


MAIN_MENU (){
if [[ ! -z $1 ]]
then
  echo $1
fi
echo "Welcome to My Salon, how may I help you?"
echo "$($PSQL "select * from services;")" | while read SERVICE_ID BAR SERVICE
do
  if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
  then
   echo "$SERVICE_ID) $SERVICE"
  fi
done
read SERVICE_ID_SELECTED
SERVICE_REQ=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED;")
if [[ -z $SERVICE_REQ ]]
then
  MAIN_MENU "That service is not available."
else
  echo "Please enter your phone number."
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo "Please enter your name:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  fi
  echo "Please enter the desired time for an appointment"
  read SERVICE_TIME
  INSERT_APP_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time)
  values($CUSTOMER_ID,$SERVICE_REQ,'$SERVICE_TIME');")
  SERVICE=$($PSQL "select name from services where service_id=$SERVICE_REQ;")
  CUSTOMER_NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")
  echo "I have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
fi
}

MAIN_MENU
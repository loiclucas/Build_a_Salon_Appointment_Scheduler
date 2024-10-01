#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Fonction pour afficher les services
DISPLAY_SERVICES() {
  echo -e "\nHere are the available services:"
  # Obtenir la liste des services et les afficher avec le format requis
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]
  then
    echo "No services available."
  else
    echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  fi
}

# Fonction pour demander un service valide
GET_SERVICE() {
  # Afficher les services
  DISPLAY_SERVICES
  
  # Demander à l'utilisateur de choisir un service
  echo -e "\nPlease enter the service ID you would like:"
  read SERVICE_ID_SELECTED
  
  # Vérifier si le service existe
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  # Si le service n'existe pas, réafficher la liste et redemander
  while [[ -z $SERVICE_NAME ]]
  do
    echo -e "\nThat is not a valid service ID."
    DISPLAY_SERVICES
    echo -e "\nPlease enter the service ID you would like:"
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  done
}

# Appeler la fonction pour demander le service
GET_SERVICE

# Demander le numéro de téléphone
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Vérifier si le client existe déjà
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  # Si le client n'existe pas, demander le nom et ajouter le client
  echo -e "\nIt looks like you are a new customer. What is your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Récupérer l'ID du client
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Demander l'heure du rendez-vous
echo -e "\nWhat time would you like your $SERVICE_NAME appointment?"
read SERVICE_TIME

# Insérer le rendez-vous dans la table appointments
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirmer la prise de rendez-vous
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

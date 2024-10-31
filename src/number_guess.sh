#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples only -c"

GAME() {
  #secret number
  SECRET=$((1 + $RANDOM % 1000))

  #count guesses
  TRIES=0

  #guess number
  # echo $SECRET
  GUESSED=0
  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GUESSED = 0 ]]; do
    read GUESS

    #if not a number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    #if correct guess
    elif [[ $SECRET = $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
      #insert into db
      INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(u_id, guesses) VALUES($USER_ID, $TRIES)")
      GUESSED=1
    #if greater
    elif [[ $SECRET -gt $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's higher than that, guess again:"
    #if smaller
    else
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done
}


 echo "Enter your username:"
  read USERNAME

  # get username from DB
  USER_ID=$($PSQL "SELECT u_id FROM users WHERE name = '$USERNAME'")

  # if user is not present
  if [[ -z $USER_ID ]]
  then
    # If u_name is not present in DB
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    # Insert to users table
    INSERTED_TO_USERS=$($PSQL "INSERT INTO users(name) values('$USERNAME')")
    # Get user_id
    USER_ID=$($PSQL "SELECT u_id FROM users WHERE name = '$USERNAME'")


  else
     # Get amount of games played
    GAMES_PLAYED=$($PSQL "SELECT count(u_id) FROM games WHERE u_id = '$USER_ID'")
    # Get best guess
    BEST_GAME=$($PSQL "SELECT min(guesses) FROM games WHERE u_id = '$USER_ID'")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

GAME


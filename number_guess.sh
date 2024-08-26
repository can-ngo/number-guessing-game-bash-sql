#!/bin/bash
echo -e "\n~~~ Number Guessing Game ~~~\n"

# define a guess function
PLAY_GUESS() {
  echo -e "\nGuess the secret number between 1 and 1000:"
  read USER_GUESS
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  while [[ $USER_GUESS -ne $RANDOM_NUMBER ]]
  do
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
      read USER_GUESS
      NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  done
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1 and 1000
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Enter your username:"
read NAME


USERNAME=$($PSQL "SELECT username FROM game WHERE username='$NAME'")
# if user doesn't exist
if [[ -z $USERNAME ]]
then
  # insert new user
  INSERT_USER=$($PSQL "INSERT INTO game(username) VALUES ('$NAME')")
  NEW_USERNAME=$($PSQL "SELECT username FROM game WHERE username='$NAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM game WHERE username='$NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM game WHERE username='$NEW_USERNAME'")
  echo -e "\nWelcome, $NEW_USERNAME! It looks like this is your first time here."
  PLAY_GUESS
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  # update number of game played
  UPDATE_GAME_PLAY=$($PSQL "UPDATE game SET games_played = $GAMES_PLAYED WHERE username = '$NEW_USERNAME'")
  # update new best game
  UPDATE_BEST_GAME=$($PSQL "UPDATE game SET best_game = $NUMBER_OF_GUESSES WHERE username = '$NEW_USERNAME'")
else # user exist
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM game WHERE username='$NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM game WHERE username='$NAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  PLAY_GUESS
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  # update number of game played
  UPDATE_GAME_PLAY=$($PSQL "UPDATE game SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
  # update new best game
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE game SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  fi
fi

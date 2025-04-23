#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Remove all entries
echo "$($PSQL "TRUNCATE games, teams")"

# Insert from database
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    # Add all winner teams to teams table IF NOT EXISTS
    TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    if [[ -z $TEAM_NAME ]]
    then
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_NAME = 'INSERT 0 1' ]]
      then
        echo "Inserted team $WINNER to table teams"
      fi
    fi
    # Obtain winner's team_id to be able to populate games table
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Add all loser teams to teams table IF NOT EXISTS
    OPPONENT_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_NAME ]]
    then
      INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_NAME == 'INSERT 0 1' ]]
      then
        echo "Inserted team $OPPONENT to table teams."
      fi
    fi
    # Obtain loser's team_id to be able to populate games table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Populate games table with data from games.csv and teams table
    MATCH_INFO=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR, '$ROUND', '$TEAM_ID', '$OPPONENT_ID', $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $MATCH_INFO == 'INSERT 0 1' ]]
    then
      echo "Inserted the match $WINNER vs $OPPONENT to the games table."
    fi
  fi
done

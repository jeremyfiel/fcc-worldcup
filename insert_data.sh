#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY;")


 cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    if [[ $YEAR != "year" ]]
    then 
    # get team_id
    TEAM_ID=$($PSQL "SELECT DISTINCT(name) FROM teams WHERE name = '$WINNER' OR name = '$OPPONENT';")
    # get winner name
    WINNER_NAME=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER';")
    # get opponent name
    OPPONENT_NAME=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT';")
    # check if either team exists
        if [[ ! $TEAM_ID ]]
        then 
        # insert both teams
        INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER'), ('$OPPONENT');")
            if [[ $INSERT_TEAM == "INSERT 0 2" ]]
            then
                echo "Inserted team(s)" $WINNER, $OPPONENT
            fi
    # check if winner exists
        elif [[ $WINNER_NAME != $WINNER ]]
        then
        # insert winner
        INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER');")
                if [[ $INSERT_TEAM ]]
            then
                echo "Inserted Winner " $WINNER
            fi
    # check if opponent exists
        elif [[ $OPPONENT_NAME != $OPPONENT ]]
        then
        # insert opponent
        INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")
                if [[ $INSERT_TEAM ]]
            then
                echo "Inserted Opponent " $OPPONENT
            fi
        fi
      fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    # get winner id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
    # get opponent id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
    if [[ $YEAR != "year" ]]
    then 
        # insert game
        INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS');")
          if [[ $INSERT_GAME = 'INSERT 0 1' ]]
          then
              echo "Inserted Game results "
          fi
    else
      echo 'Unable to insert game.'
    fi
done
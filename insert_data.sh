#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE teams, games"

cat games.csv | while  IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
  #teams table:
  #insert winner teams into teams
    TEAM_ID="$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")"
    if [[ -z $TEAM_ID && $WINNER != 'winner' ]]
      then 
        INSERT_WINNING_TEAMS_ID=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
        #echo team name as its inserted
        if [[ $INSERT_WINNING_TEAMS_ID == 'INSERT 0 1' ]]
          then 
            echo "Inserted $WINNER"
          fi
    fi

    #insert opponent teams into teams
        TEAM_ID="$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")"
    if [[ -z $TEAM_ID && $OPPONENT != 'opponent' ]]
      then 
        INSERT_OPPONENT_TEAMS_ID=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
        #echo team name as its inserted
        if [[ $INSERT_OPPONENT_TEAMS_ID == 'INSERT 0 1' ]]
          then 
            echo "Inserted team: $OPPONENT"
          fi
    fi
  #games table:
  #loop over every game and insert id, year round winner_goals, opponent_goals
    INSERT_GAMES=$($PSQL "INSERT INTO games( year, round, winner_goals, opponent_goals, winner_id, opponent_id) 
    VALUES ($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, 
    (SELECT team_id FROM teams WHERE name='$WINNER'), 
    (SELECT team_id FROM teams WHERE name='$OPPONENT'))")
    if [[ $INSERT_GAMES == 'INSERT 0 1' ]]
      then
        echo "Inserted game: $WINNER / $OPPONENT $ROUND $YEAR"
      fi
  done

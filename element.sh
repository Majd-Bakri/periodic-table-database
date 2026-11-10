#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# Search by atomic number, symbol, or name
if [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT=$($PSQL "
    SELECT e.atomic_number, e.name, e.symbol,
           p.atomic_mass, t.type,
           p.melting_point_celsius,
           p.boiling_point_celsius
    FROM elements e
    JOIN properties p
      ON e.atomic_number = p.atomic_number
    JOIN types t
      ON p.type_id = t.type_id
    WHERE e.atomic_number = $1
  ")
elif [[ $1 =~ ^[A-Za-z]+$ ]]
then
  ELEMENT=$($PSQL "
    SELECT e.atomic_number, e.name, e.symbol,
           p.atomic_mass, t.type,
           p.melting_point_celsius,
           p.boiling_point_celsius
    FROM elements e
    JOIN properties p
      ON e.atomic_number = p.atomic_number
    JOIN types t
      ON p.type_id = t.type_id
    WHERE e.symbol = '$1'
       OR e.name = '$1'
  ")
else
  echo "I could not find that element in the database."
  exit 0
fi

# Handle element not found
if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Extract element information
IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL \
ATOMIC_MASS TYPE MELTING_POINT BOILING_POINT <<< "$ELEMENT"

# Print element details
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."

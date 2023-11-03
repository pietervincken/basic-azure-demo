#!/bin/bash

echo "INSERT INTO users(firstname, lastname, gender) VALUES" > users.sql

curl "https://randomuser.me/api/?inc=gender,name&format=json&results=5000&nat=gb" \
    | jq ".results[]| \"('\" + .name.first + \"', '\" + .name.last + \"', '\" + .gender + \"'),\"" --raw-output >> users.sql

sed -i '' '$ s/.$//' users.sql # remove last , as it's incorrect

echo ";" >> users.sql
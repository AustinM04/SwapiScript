#!/bin/bash

base_url=https://swapi.dev/api/starships/
response=$(curl -k -sS https://swapi.dev/api/starships/ | jq '.')
echo "Response: "
echo $response

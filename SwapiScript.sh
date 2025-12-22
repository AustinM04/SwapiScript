#!/bin/bash
# SwapiScript.sh
# This script fetches and displays starship names from the Star Wars API (SWAPI).
# Introduction text that introduces the script
separator_bar="---------------------------------------------"

echo "----Starting SWAPI Starships Fetch Script----"
echo $separator_bar
echo "A long time ago in a galaxy far, far away...."
echo $separator_bar

# Using the base url for starships, variable is later used to hold the next page url
next_url=https://swapi.dev/api/starships/

# Fetching the total count of starships, displayed at the start
# Using -k to ignore SSL certificate issues, which SWAPI is currently having
# During production use, -k  (if possible) be avoided to ensure secure connections
count=$(curl -k -sS $next_url | jq '.count')

# Displaying the total count of starships
echo "Total Starships: $count"
echo $separator_bar
echo "Starship Names and their Pilots:"

# Looping through all pages of starships
while [ "$next_url" != "null" ] && [ -n "$next_url" ]; do

    # Used for debugging purposes to show which page is being fetched
    echo "Fetching starships from: $next_url"
    echo $separator_bar

    # Fetching the current page of starships and storing the response
    response=$(curl -k -sS $next_url)

    # Setting the next_url to the next page link from the response
    next_url=$(echo "$response" | jq -r '.next')

    # Looping through each starship in the current page
    # Using jq -c to output each starship as a compact JSON object on a single line 
    # Using while read loop to process each starship JSON object from each individual line that jq outputs
    echo "$response" | jq -c '.results[]' | while read -r starship_json; do

        # Extracting the starship name and displaying it
        starship_name=$(echo "$starship_json" | jq -r '.name')
        echo "Starship: $starship_name"

        # Extracting the pilot URLs
        pilots=$(echo "$starship_json" | jq -r '.pilots[]?')

        # Using -z to check if the pilots variable is empty
        # Indenting the pilot output for better readability
        if [ -z "$pilots" ]; then

            # Outputting that there are no pilots listed if the pilots variable is empty
            echo "  Pilots: None Listed"
        else

            # Looping through each pilot URL to fetch and display the pilot names
            echo "  Pilots:"

            # Fetching and displaying each pilot's name
            for pilot_url in $pilots; do

                # Fetching the pilot's name from the pilot URL
                pilot_name=$(curl -k -sS $pilot_url | jq -r '.name')
                echo "    - $pilot_name"
            done
        fi

        # Adding a separator line after each starship for better readability
        echo "---------------------------------------------"
    done
done

# Ending text to show that the script has finished running
echo ""
echo "----Finished fetching all starships & their pilots!----"
exit 0
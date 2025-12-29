#!/usr/bin/env python3
import requests
import urllib3

# NOTE: I used the urllib3.disable_warnings to disable ssl warnings because the API
#   has an invalid ssl cert right now and because I am using the verify=False, this
#   will silence the warnings saying that is unsafe to use.

# NOTE: verify=False disables the ssl checking and is used on all of my get statements



# Silencing the ssl warnings 
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def fetch_starship_info():
    # Prints opening statement
    print("-" * 45)
    print("Starting SWAPI starship info fetching script")
    print("-" * 45)
    print("A long time ago in a galaxy far, far away....")
    print("-" * 45)

    # Holds the initial url and the page urls as we progress
    url = "https://swapi.dev/api/starships/"
    
    # Creating the session that will be used to talk to the api
    #   NOTE: This will be 5x - 10x quicker than the individual curl statements
    session = requests.Session()

    # This will act as a cache for the pilot URLs that we have already seen to
    #   quickly get the info for an already queried pilot.
    pilot_cache = {}

    # Attempting to get the initial count
    try:
        response = session.get(url, verify=False)
        data = response.json()
        print(f"Total Starships: {data['count']}")
    except Exception as e:
        print("Error getting the number of starships.")
        return

    print("-" * 45)
    print("Starship names and their Pilots:")

    while url:
        try:
            # Fetching the page
            response = session.get(url, verify=False)

            # Turning our response into json for easier parsing
            data = response.json()

            # Update the next page url for the paginated data
            url = data['next']

            # Looping for each ship in the results
            for ship in data['results']:
                print(f"Starship: {ship['name']}")

                # Getting the list of pilots that each ship has
                pilots = ship.get('pilots', [])
                if not pilots:
                    print(" Pilots: None Listed")
                else:
                    print(" Pilots:")
                    # Looping through the pilot urls in the array of pilots
                    for pilot_url in pilots:
                        # Checking the cache first to avoid wasting time
                        if pilot_url in pilot_cache:
                            # Fetching the pilot's name from the cache using the url as a key
                            pilot_name = pilot_cache[pilot_url]
                        else:
                            # Fetching and saving to cache if new
                            try:
                                # Fetching the pilot page
                                pilot_response = session.get(pilot_url, verify=False)
                                # Converting to json and parsing to find name field
                                pilot_name = pilot_response.json()['name']
                                # Keying the name to the pilot url in cache
                                pilot_cache[pilot_url] = pilot_name
                            except:
                                pilot_name = "Error getting pilot information"
                        
                        print(f"  -{pilot_name}")

                print("-"*45)

        except Exception as e:
            print(f"Error: {e}")
            break
    
    print()
    print("-"*45)
    print("Done fetching all starships & their pilots!")
    print("-"*45)

# Ensuring we only run the script when directly executing the script
if __name__ == "__main__":
    fetch_starship_info()


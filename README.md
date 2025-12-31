# Star Wars API Starship \& Pilot Reporter (SWAPI)

**Author:** Austin Moore



This project queries the Star Wars API to receive all starships and prints each starship along with all the associated pilots or none listed if no pilots are listed. The solution is packaged into a Docker container using ubuntu:latest and it can be run with a single `docker run` command.



##### Approach:

I started by breaking the problem down into the smallest testable parts:

 1. Confirm I could retrieve starship data from SWAPI

 2. Handle the pagination

 3. Fetch and display the pilot names

 4. Package everything into a reproducible Docker image.



My initial prototype was in Bash using curl and jq. I built a majority of the script out in bash, but after some testing, I determined to migrate to Python because it offered a significant speed improvement which can be attributed to the speed of print statements and connection reuse through requests.Session. The use of python was also still minimal on resource usage.



Implementation details:

* Pagination: Follows SWAPI's next URL until the next link does not exist.
* Pilot retrieval: For each starship, it iterates through the pilots array and fetches the pilot pages.
* Caching: Pilot URLs are cached in memory to avoid refetching the same pilot multiple times across starships. This is significantly faster than without the cache as it avoids 20+ fetches.
* Error handling: The network operations are wrapped in try/except blocks and prints readable error messages rather than crashing.



##### Notes \& Assumptions:

* SWAPI SLL warning: At the time of writing the script, SWAPI was presenting SSL certificate issues, to get around this the script uses verify=False and disables the resulting urllib3 warnings to keep the stdout clean and readable.
* The output is designed to be human readable and written to stdout.
* Assumption: The user has installed docker desktop
* Assumption: User has access to the terminal and has root access



##### Running the Container:

1. Ensure docker is installed, open the the terminal and run "docker --version", if docker is not installed, make sure that docker desktop is installed
2. If docker is installed, in the terminal run "docker pull ghcr.io/austinm04/swapi-script:latest" to pull the latest version of the docker container
3. To run the docker container, in the terminal run "docker run ghcr.io/austinm04/swapi-script:latest"
4. The script will run and let you know when it is done!





##### Production Deployment Considerations:

If I were to deploy this solution in a production environment, I would focus on making the script more robust, automated, and secure. This is how I would approach those challenges:



###### 1\. Container Orchestration \& Scaling

Since this is a batch script (runs once and exits), I would use Kubernetes CronJobs.

* Scheduling: The Kubernetes CronJob would handle the schedule, e.g. running each day to retrieve updated data
* Restart Policies: If the script crashes due to a temporary network glitch, the system should automatically attempt to restart it or retry the failed request.

If the dataset were to grow to millions of starships my current approach would be extremely slow.

* Parallelism: I would modify the script to process data in parallel. Instead of fetching one ship details and pilots at a time, I could use python's multiprocessing to fetch multiple concurrently, significantly reducing total runtime.
* Database storage: Instead of printing out to the screen, I would modify the script to write the results to a database so that other applications could actually use the data.



###### 2\. Monitoring \& Logging

In a production setting we wouldn't want to look at the terminal to see if the script worked, so we could take the following approach for a more robust approach to monitoring and logging.

* Logging: I would send the script's output to a logging system like the ELK stack. This would allow us to search through past logs and quickly see  if the script failed or if the api was down.
* Health Checks: I could set up alerts to notify the presumed team immediately if a script run crashes or takes too long to finish. This would make sure that we could address issues before they become big problems.



###### 3\. CI/CD Pipeline \& Configuration Management

I have already implemented the foundation of a CI/CD pipeline using GitHub actions.

* Automation: My current setup already detects changes to the code, builds a new Docker image, and pushes it to the GitHub Container Registry. With this setup I am able to make sure that the live version of the container is always using the latest code.
* Configuration: For a production deployment, I would move the hardcoded settings like the API URL into configuration files or environment variables. This allows us to easily switch between test and production modes without rewriting the code.



###### 4\. Security \& Reliability

* Secrets management: Currently for my GitHub actions workflow, I use GitHub secrets to hide my auth tokens. In a production setting, I would expand this to ensure that no sensitive data such as database passwords or API keys is ever visible in the code.
* Base images: I would use a base image like python:\*-slim to avoid the pitfalls of using ubuntu, which opens us up to numerous security vulnerabilities by exposing a larger attack surface which includes software that is not needed for the application to run. Additionally, using the slim image significantly reduces the size of the image.
* Vulnerability Scanning: To improve security, I would integrate a scanning tool such as Trivy or Snyk into the pipeline to automatically check the Docker image for known security flaws before each deployment. Docker desktop already gives us this convenience for local development as they have a new feature that scans the images and lets you know if there are any security considerations you should know about.
* SSL Verification: Currently, in the script, I have made it so that the script bypasses SSL checks due to the API's expired certificate. In a real production environment, fixing this would be a priority as we would want to make sure that all data connections are fully encrypted and data security is ensured.

# Makes sure that we are using the latest version of Ubuntu
FROM ubuntu:latest

# Install necessary dependencies and efficiently clean up apt cache to reduce image size
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Using an environment variable for the script path for a DRY approach
ENV SCPATH="/usr/local/bin/swapiscript.sh"

# Copy the script to the container
COPY SwapiScript.sh $SCPATH

# Make the script executable to all users
RUN chmod +x $SCPATH

# Set the default command to execute the script
CMD ["/usr/local/bin/swapiscript.sh"]


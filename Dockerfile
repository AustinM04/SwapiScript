# Makes sure that we are using the latest version of Ubuntu
FROM ubuntu:latest

# Install necessary dependencies and efficiently clean up apt cache to reduce image size
RUN apt-get update && apt-get install -y \
    python3 \
    python3-requests\
    && rm -rf /var/lib/apt/lists/*

# Using an environment variable for the script path for a DRY approach
ENV SCPATH="/usr/local/bin/script.py"

# Turn off python buffering to see updates in real time
ENV PYTHONUNBUFFERED=1

# Copy the script to the container
COPY script.py $SCPATH

# Make the script executable to all users
RUN chmod +x $SCPATH

# Set the default command to execute the script
CMD ["/usr/local/bin/script.py"]


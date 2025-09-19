FROM ubuntu:24.04

WORKDIR /app

COPY . /app

# Install prerequisites for Wisecow
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fortune-mod fortunes-min cowsay netcat-openbsd curl && \
    rm -rf /var/lib/apt/lists/*

# Make sure binaries are in PATH
ENV PATH="/usr/games:${PATH}"

# Expose the port Wisecow uses
EXPOSE 4499

# Run the Wisecow script
CMD ["./wisecow.sh"]


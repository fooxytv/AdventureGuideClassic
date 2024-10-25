FROM ubuntu:latest

# Install necessary packages including dos2unix
RUN apt-get update && apt-get install -y \
    zip \
    git \
    curl \
    bash \
    luarocks \
    dos2unix \
    && luarocks install luacheck

WORKDIR /app

# Copy the scripts into the container
COPY ./ci/scripts ./ci/scripts

# Convert line endings for consistency
RUN dos2unix ./ci/scripts/*.sh

# Run chmod on the scripts
RUN chmod +x ./ci/scripts/*.sh

CMD ["bash"]
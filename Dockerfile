# steelboot/Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Add universe repository
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update

# Optional: Just check what's available
RUN apt-cache search scap

# Install openscap-utils (scap-security-guide not available in Ubuntu 24.04)
RUN apt-get install -y openscap-utils || { echo "Error: failed to install openscap-utils"; exit 1; }

# Now install the rest
RUN apt-get install -y \
    ansible \
    git \
    curl \
    python3-pip \
    sudo \
    openssh-client && \
    apt-get clean

# Create directory for generated playbook (will be copied from generator container)
RUN mkdir -p /opt/steelboot/ansible/harden

RUN mkdir -p /var/log

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


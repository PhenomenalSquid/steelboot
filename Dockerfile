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

# Try installing only openscap-utils
RUN apt-get install -y openscap-utils || { echo "Error: failed to install openscap-utils"; exit 1; }

# Then try scap-security-guide
RUN apt-get install -y scap-security-guide || { echo "Error: failed to install scap-security-guide"; exit 1; }

# Now install the rest
RUN apt-get install -y \
    ansible \
    git \
    curl \
    python3-pip \
    sudo \
    openssh-client && \
    apt-get clean

RUN mkdir -p /opt/steelboot/ansible/harden && \
    oscap xccdf generate fix \
    --fix-type ansible \
    --profile xccdf_org.ssgproject.content_profile_cis \
    --output /opt/steelboot/ansible/harden/ubuntu2204-cis.yml \
    /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-xccdf.xml

RUN mkdir -p /var/log

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


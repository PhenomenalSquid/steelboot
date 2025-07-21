# steelboot

**steelboot** is a containerized admin toolkit designed to bootstrap, harden, and deploy secure components on top of a fresh Ubuntu system.

It runs from a Docker container and applies infrastructure configuration via Ansible playbooks and roles — with optional offline mode for environments without internet access.

---

## Goals

-  Harden default Ubuntu installs using sane, secure-by-default settings
-  Easily deploy tools like Tomcat with TLS, sane permissions, and safe configs
-  Provide a single, flexible container you can run anywhere
-  Support both **online** (pull Ansible repo) and **offline** (bundled copy) modes

---

## Usage
#still building this!

```bash
# Example: Harden the host system  
sudo docker run --rm --privileged -v /:/mnt steelboot

# Example: Deploy Tomcat with sensible defaults
sudo docker run --rm --privileged -v /:/mnt steelboot --deploy-tomcat

# Optional: Run in offline mode (uses bundled Ansible playbooks)
sudo docker run --rm --privileged -v /:/mnt steelboot --harden --offline


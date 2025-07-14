#!/bin/bash
set -e

echo "[steelboot] Building SCAP playbook generator container..."
docker build -f Dockerfile.generator -t steelboot-gen .

echo "[steelboot] Creating temp container..."
cid=$(docker create steelboot-gen)

echo "[steelboot] Copying generated playbook to ansible/harden/..."
docker cp "$cid":/output/ubuntu2204-cis.yml ansible/harden/ubuntu2204-cis.yml

echo "[steelboot] Cleaning up temp container..."
docker rm "$cid"

echo "[steelboot] Done. Playbook ready at ansible/harden/ubuntu2204-cis.yml"


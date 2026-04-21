#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly IMAGE_TAG="qest-formats-ae:2026"
readonly IMAGE_TAR="${SCRIPT_DIR}/qest-formats-ae-image.tar.gz"
readonly INSTANCES_DIR="${SCRIPT_DIR}/instances"

mkdir -p "${INSTANCES_DIR}"

if ! docker image inspect "${IMAGE_TAG}" >/dev/null 2>&1 && [[ -f "${IMAGE_TAR}" ]]; then
  echo "[artifact] Loading docker image from ${IMAGE_TAR}"
  docker load -i "${IMAGE_TAR}" >/dev/null
fi

echo "[artifact] Running dlinear"
docker run --rm \
  -v "${INSTANCES_DIR}:/instances" \
  --entrypoint ./binary_impl.sh \
  "${IMAGE_TAG}" $@

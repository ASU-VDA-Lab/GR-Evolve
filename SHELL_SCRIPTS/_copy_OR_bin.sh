
#!/usr/bin/env bash
set -euo pipefail

BUILD_ROOT="/root/OpenROAD_New_GRT"
ORFS_ROOT="/root/OpenROAD-flow-scripts"

SRC_BIN="${BUILD_ROOT}/build/bin/openroad"
CUSTOM_BIN="${BUILD_ROOT}/build/bin/ornewgr2"
ORFS_BIN="${ORFS_ROOT}/flow/tools/ornewgr2"

if [ ! -x "${SRC_BIN}" ]; then
  echo "Error: ${SRC_BIN} does not exist or is not executable." >&2
  exit 1
fi

cp -f "${SRC_BIN}" "${CUSTOM_BIN}"
chmod +x "${CUSTOM_BIN}"

# rm -f "${ORFS_BIN}"
# cp -f "${CUSTOM_BIN}" "${ORFS_BIN}"
# chmod +x "${ORFS_BIN}"

echo "[COPY] Updated OpenROAD binary copied to:"
echo "[COPY] OpenROAD binary compiled from ${SRC_BIN} to ${CUSTOM_BIN}"
# echo "  ${ORFS_BIN}"

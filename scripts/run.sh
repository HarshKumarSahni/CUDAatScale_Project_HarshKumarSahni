#!/usr/bin/env bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${ROOT}/build"
BIN_DIR="${ROOT}/bin"
OUT_DIR="${ROOT}/outputs/processed"
LOG_DIR="${ROOT}/outputs/logs"
DATA_DIR="${ROOT}/data_in"

mkdir -p "${BUILD_DIR}" "${BIN_DIR}" "${OUT_DIR}" "${LOG_DIR}" "${DATA_DIR}"

# Build
echo "Building..."
cd "${ROOT}"
make

# Generate data (python script)
echo "Generating synthetic dataset..."
python3 scripts/generate_data.py

# Run using GPU if available
echo "Running image processor (GPU if available)..."
./bin/process_images --in_dir "${DATA_DIR}" --out_dir "${OUT_DIR}" || { echo "GPU run failed, trying CPU fallback"; ./bin/process_images --in_dir "${DATA_DIR}" --out_dir "${OUT_DIR}" --cpu; }

# Copy log to outputs/logs
cp -v outputs/processed/../logs/run_log.txt "${LOG_DIR}/run_log_$(date +%Y%m%d_%H%M%S).txt"

echo "Done. Processed images in ${OUT_DIR}, logs in ${LOG_DIR}"

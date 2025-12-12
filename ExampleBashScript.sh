#!/bin/bash
#SBATCH -J stanley_test1338
#SBATCH -N 1
#SBATCH -p batch
#SBATCH -n 1
#SBATCH -c 8
#SBATCH -t 02:00:00
#SBATCH --mem=16g
#SBATCH --array=1-1%1
#SBATCH -o /dev/null
#SBATCH -e /dev/null

set -euo pipefail

# ===============================
# USER CONFIGURATION
# ===============================

TargetList=('260128333')  # TIC 260128333

RUN_ROOT="/cluster/tufts/martinlab/tklean01/testing/PUBLIC_RELEASE_STANLEY/Runs"
mkdir -p "${RUN_ROOT}"

LOG_DIR="${RUN_ROOT}/logs"
mkdir -p "${LOG_DIR}"

CONDA_ENV="stanley_env"

RUN_TAG="TestRunTOI1338"
DETRENDBASE="Detrend_${RUN_TAG}_"
SEARCHBASE="Search_${RUN_TAG}_"

# ===============================
# SELECT TARGET
# ===============================

index=$((SLURM_ARRAY_TASK_ID - 1))
TIC_ID="${TargetList[$index]}"

exec > "${LOG_DIR}/stanley-${RUN_TAG}-out-TIC${TIC_ID}.txt" \
     2> "${LOG_DIR}/stanley-${RUN_TAG}-err-TIC${TIC_ID}.txt"

echo "[INFO $(date +'%F %T')] Starting job for TIC${TIC_ID}"

# ===============================
# ENVIRONMENT SETUP
# ===============================

# We assume "conda" is on PATH (same as your login shell)
if ! command -v conda >/dev/null 2>&1; then
    echo "[ERROR] 'conda' command not found in PATH. Did you load the right module or set up conda in your shell?" >&2
    exit 1
fi

CONDA_BASE="$(conda info --base)"
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate "${CONDA_ENV}"

echo "[INFO] Using conda base: ${CONDA_BASE}"
echo "[INFO] Python: $(which python)"
python -V

WORK_DIR="${RUN_ROOT}"
export STANLEY_WORKDIR="${WORK_DIR}"
cd "${WORK_DIR}"

echo "[INFO] Working directory (STANLEY_WORKDIR): ${WORK_DIR}"

python - << 'EOF'
from stanley_cbp import Stanley_Functions as AC
print("base_dir():", AC.base_dir())
print("LightCurves root:", AC.p_lightcurves())
print("UserGeneratedData root:", AC.p_user_data(""))
print("PlanetSearchOutput root:", AC.p_outputs("TEST_SEARCH"))
EOF

# ===============================
# RUN STANLEY PIPELINE
# ===============================

SYSTEM_ARG="TIC${TIC_ID}"
DETREND_NAME="${DETRENDBASE}${TIC_ID}"
SEARCH_NAME="${SEARCHBASE}${TIC_ID}"

echo "[INFO] Using:"
echo "  SYSTEM_ARG    = ${SYSTEM_ARG}"
echo "  DETREND_NAME  = ${DETREND_NAME}"
echo "  SEARCH_NAME   = ${SEARCH_NAME}"

echo "[INFO $(date +'%F %T')] Running detrending..."
python -m stanley_cbp.Stanley_Detrending \
    --systemName="${SYSTEM_ARG}" \
    --detrendingName="${DETREND_NAME}" \
    --useSavedData=0

echo "[INFO $(date +'%F %T')] Running short bounded planet search..."
python -m stanley_cbp.Stanley_PlanetSearch_InterpN_DebugPadding \
    --systemName="${SYSTEM_ARG}" \
    --searchName="${SEARCH_NAME}" \
    --detrendingName="${DETRENDBASE}${TIC_ID}" \
    --totalSectors=4 \
    --parallel=1 \
    --onCluster=1 \
    --interpolationValue=2 \
    --boundsType="days to days" \
    --minValue=90 \
    --maxValue=98

echo "[INFO $(date +'%F %T')] Running analysis..."
python -m stanley_cbp.Stanley_Analysis_InterpN \
    --systemName="${SYSTEM_ARG}" \
    --searchName="${SEARCH_NAME}" \
    --totalSectors=4 \
    --onCluster=1

echo "[INFO $(date +'%F %T')] Completed TIC${TIC_ID}"

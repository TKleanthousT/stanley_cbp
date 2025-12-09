#!/bin/bash
#SBATCH -J stanley_cbp-run                   # Job name
#SBATCH -N 1                             # Nodes
#SBATCH -p batch                         # Partition/queue (edit as needed)
#SBATCH -n 1                             # Tasks per node
#SBATCH -c 8                             # CPU cores per task
#SBATCH -t 7-00:00:00                    # Walltime (7 days)
#SBATCH --mem=32g                        # Memory
#SBATCH --array=1-1%1                    # Array range (edit for multiple targets)

# Optional: SLURM-managed stdout/stderr
# SBATCH -o /path/to/logs/slurm-%x-%A_%a.out
# SBATCH -e /path/to/logs/slurm-%x-%A_%a.err


# ===============================
# USER CONFIGURATION
# ===============================

# Example list of TIC IDs (without the "TIC" prefix)
TargetList=('231275247')

# Directory for manual log redirection (user-specific)
LOG_DIR="/path/to/stanley_logs"

# Conda setup (edit to match your HPC)
ANACONDA_MODULE="anaconda/2021.xx"
CONDA_ENV="stanley_env"     # Name of the environment created from environment.yml

# Run labels (safe, generic names)
RUN_TAG="ExampleRun"
DETRENDBASE="Example_Detrend_"
SEARCHBASE="Example_Search_"

# ===============================
# SELECT TARGET FOR THIS ARRAY JOB
# ===============================

index=$((SLURM_ARRAY_TASK_ID - 1))
TIC_ID="${TargetList[$index]}"

mkdir -p "${LOG_DIR}"

# Manual stdout/stderr redirection
exec >  "${LOG_DIR}/stanley_cbp-${RUN_TAG}-out-${TIC_ID}.txt" \
     2> "${LOG_DIR}/stanley_cbp-${RUN_TAG}-err-${TIC_ID}.txt"

echo "[INFO $(date +'%F %T')] Starting job for TIC${TIC_ID}"


# ===============================
# ENVIRONMENT SETUP
# ===============================

# (Optional) HPC-specific module loading
module load "${ANACONDA_MODULE}"

# Activate the conda environment
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "${CONDA_ENV}"

# ===============================
# RUN STANLEY PIPELINE
# ===============================

SYSTEM_ARG="TIC${TIC_ID}"
DETREND_NAME="${DETRENDBASE}${TIC_ID}"
SEARCH_NAME="${SEARCHBASE}${TIC_ID}"

echo "[INFO $(date +'%F %T')] Running detrending..."
python Stanley_Detrending.py \
    --systemName="${SYSTEM_ARG}" \
    --detrendingName="${DETREND_NAME}" \
    --useSavedData=0

echo "[INFO $(date +'%F %T')] Running planet search..."
python Stanley_PlanetSearch_InterpN_DebugPadding.py \
    --systemName="${SYSTEM_ARG}" \
    --searchName="${SEARCH_NAME}" \
    --detrendingName="${DETREND_NAME}" \
    --totalSectors=32 \
    --parallel=1 \
    --onCluster=1 \
    --interpolationValue=2

echo "[INFO $(date +'%F %T')] Running analysis..."
python Stanley_Analysis_InterpN.py \
    --systemName="${SYSTEM_ARG}" \
    --searchName="${SEARCH_NAME}"

echo "[INFO $(date +'%F %T')] Job for TIC${TIC_ID} completed"

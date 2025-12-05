#!/bin/bash
#SBATCH -J stanley-run                          # Job name
#SBATCH -N 1                                    # Nodes
#SBATCH -p batch                                # Partition/queue
#SBATCH -n 1                                    # Tasks per node
#SBATCH -c 8                                    # CPU cores per task
#SBATCH -t 7-00:00:00                           # Walltime (7 days)
#SBATCH --mem=32g                               # Memory
#SBATCH --array=1-1%1                           # Array range (matches TargetList length; edit as needed)
# SBATCH -o /path/to/slurm-%x-%A_%a.out         # Optional: SLURM-managed stdout
# SBATCH -e /path/to/slurm-%x-%A_%a.err         # Optional: SLURM-managed stderr

# USER CONFIG

# Target list (TIC IDs only; do not include the "TIC" prefix here)
TargetList=('231275247')                         # Add more IDs as needed

# Log directory for manual redirection
LOG_DIR="/cluster/tufts/martinlab/tklean01/stanley_public_release_pip_installable_FINAL/scripts_output"

# Environment (module + conda environment name)
ANACONDA_MODULE="anaconda/2021.11"
CONDA_ENV="stanley"

# Run labels
RUN_TAG="ANTIC_FullCatalog-LongTest-NoArgoPMult-DSA32Sect8Cores"
DETRENDBASE="ANTIC_Full_Catalog_Detrend_LongTest_32Sect8CoresTIC"
SEARCHBASE="ANTIC_Full_Catalog_Search_LongTest_32Sect8CoresTIC"

# Compute array index and select TIC
index=$((SLURM_ARRAY_TASK_ID - 1))
TIC_ID="${TargetList[$index]}"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Manual redirection (stdout & stderr)
exec >  "${LOG_DIR}/tklean-${RUN_TAG}-analysis-out-${TIC_ID}.txt" 2> "${LOG_DIR}/tklean-${RUN_TAG}-analysis-err-${TIC_ID}.txt"

echo "[INFO $(date +'%F %T')] Starting job for TIC${TIC_ID} (SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID})"

# Network: Disable proxies for MAST and related hosts
export NO_PROXY="mast.stsci.edu,.mast.stsci.edu,stsci.edu,.stsci.edu,localhost,127.0.0.1"
export no_proxy="$NO_PROXY"
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy
unset REQUESTS_CA_BUNDLE CURL_CA_BUNDLE

# Environment: Load Anaconda and activate the desired conda env
module load "${ANACONDA_MODULE}"
source activate "${CONDA_ENV}"

# Re-assert proxy settings in case the module or env changed them
export NO_PROXY="mast.stsci.edu,.mast.stsci.edu,stsci.edu,.stsci.edu,localhost,127.0.0.1"
export no_proxy="$NO_PROXY"
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy
unset REQUESTS_CA_BUNDLE CURL_CA_BUNDLE

# Paths/Names
SYSTEM_ARG="TIC${TIC_ID}"
DETREND_NAME="${DETRENDBASE}${TIC_ID}"
SEARCH_NAME="${SEARCHBASE}${TIC_ID}"


# Step 1: Detrending (uses live downloads; set --useSavedData=1 to use cached)
echo "[INFO $(date +'%F %T')] Running detrending for ${SYSTEM_ARG}"
python Stanley_Detrending.py --systemName="${SYSTEM_ARG}" --detrendingName="${DETREND_NAME}" --useSavedData=0

# Step 2: Planet search (parallel over sectors; interpolation N=2; on cluster)
echo "[INFO $(date +'%F %T')] Running planet search (parallel) for ${SYSTEM_ARG}"
python Stanley_PlanetSearch_InterpN.py --systemName="${SYSTEM_ARG}" --searchName="${SEARCH_NAME}" --detrendingName="${DETREND_NAME}" --totalSectors=32 --parallel=1 --onCluster=1 --interpolationValue=2

# Step 3: Analysis/aggregation
echo "[INFO $(date +'%F %T')] Running analysis for ${SYSTEM_ARG}"
python Stanley_Analysis_InterpN.py --systemName="${SYSTEM_ARG}" --searchName="${SEARCH_NAME}"

echo "[INFO $(date +'%F %T')] Completed job for TIC${TIC_ID}"

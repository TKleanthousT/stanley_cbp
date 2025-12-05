# Stanley Pipeline

**Stanley** is a research pipeline for detecting, modeling, and analyzing **eclipsing binaries** and potential **circumbinary planets (CBPs)** in space-based photometric data. It was originally developed for the **Kepler** CBP sample and has since been extended and adapted for large-scale searches in **TESS** light curves. In circumbinary systems, planetary transits do **not** occur at regular intervals and transit durations vary significantly due to the orbital motion of both stars around the barycenter. As a result, conventional single-star transit search algorithms perform poorly. **Stanley** implements methods specifically optimized for the **variable-timing and variable-duration** transit signatures unique to circumbinary planets.

## Core Capabilities
### Detrending
- Iterative cosine (COFIAM-like) filtering
- TESS-specific quadratic baseline removal
- Variable-duration biweight filters
- Outlier / flare / kink removal
- Optional ellipsoidal and reflection trend modeling (BIC-based)

### Binary Modeling & Validation
- Robust eclipse identification
- Period and harmonic validation using multi-stage BLS
- Binary geometry extraction (P, e, ω, eclipse depths/widths)
- Statistical detrending-quality metrics

### Secondary Eclipse Vetting
- Geometric feasibility tests
- Inclination / eccentricity constraints
- Monte Carlo eclipse-probability estimation
- Thermal and reflected-light depth checks

### Transit Timing Variation Search
- N-body forward modeling via **REBOUND**
- Variable-duration transit stacking matched to dynamically predicted timing signatures

### Scalable Execution
- Fully HPC-compatible (SLURM)
- Each module (detrending, search, analysis) may run independently or as a unified pipeline

## Scientific Context (Condensed)
The pipeline was first validated on the **Kepler** circumbinary-planet sample, where it successfully recovered all known CBPs including **Kepler-47 b/c/d**, searched for additional planets using variable-duration stacked transit detection, and demonstrated that planets smaller than ~3 R⊕ would have been detectable in roughly half the systems. The current implementation extends the approach to **TESS**, with the goals of searching low-mass eclipsing binaries, identifying new CBP candidates, and constraining the **occurrence rate** of small circumbinary planets.

## Repository Structure & Data Requirements
This repository contains only the **source code** (`stanley/`). Runtime data must live in a user-defined directory called the **Stanley base directory**. Set:
export STANLEY_BASE=/path/to/stanley_data

Your STANLEY_BASE directory must contain the following folders:
STANLEY_BASE/
    Databases/               (REQUIRED; holds static catalogs such as ANTIC_Catalogue_*.csv, common_false_positives.csv, villanova_orbit_data_kepler.csv, villanova_orbit_data_tess.csv)
    LightCurves/             (REQUIRED; contains Raw/, Processed/, Figures/, Stats/, and other helper files used by the pipeline; created and populated by the code as needed)
    PlanetSearchOutput/      (created automatically by Stanley_FindPlanets)
    DiagnosticReports/       (created automatically; stores PDF diagnostic reports)

Both Databases/ and LightCurves/ must exist before running the pipeline. The other folders will be created automatically. Keeping these folders in your development repository does not affect pip installation, because the wheel only packages the `stanley/` code directory.

## Installation
Install from a future PyPI release:
pip install stanley

Or install from a locally built wheel:
pip install dist/stanley-0.1.X-py3-none-any.whl

## Using Stanley in Python
from stanley import runDetrendingModule, Stanley_FindPlanets, runAnalysisModule

# 1. Detrending
result_det = runDetrendingModule(
    SystemName="TIC260128333",
    DetrendingName="DemoDetrend",
    UseSavedData=0,
)

# 2. Search
Stanley_FindPlanets(
    SearchName="DemoSearch",
    SystemName="TIC260128333",
    DetrendingName="DemoDetrend",
    totalSectors=1,
    currentSector=1,
)

# 3. Analysis
analysis_out = runAnalysisModule(
    searchName="DemoSearch",
    systemName="TIC260128333",
    totalSectors=1,
)

## Tutorials
A `Tutorials/` directory is provided for example notebooks. These notebooks assume: (1) a local `stanley` installation, (2) a valid STANLEY_BASE directory containing Databases/ and LightCurves/, and (3) that the pipeline downloads or generates all other required subfolders automatically. Tutorials demonstrate detrending, running the CBP search, interpreting outputs, and generating diagnostic figures.

## Licensing
This package is released under the **MIT License**.


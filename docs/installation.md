# Installation
This page explains how to install the STANLEY pipeline in a clean and reliable way. The instructions assume basic familiarity with Python environments but do not require advanced setup.

# Requirements
- Python ≥ 3.9
- A working scientific Python stack (NumPy, SciPy, pandas)
- Recommended: a conda or venv environment (a base environment.yml file is included at the top level of the repository)
- Internet connection for installing dependencies

# Installation
Install from PyPI: pip install stanley_cbp
Or install from a locally built wheel: pip install dist/stanley_cbp-0.1.X-py3-none-any.whl

# Environment setup (recommended)
For reproducible installations, this repository provides two Conda environment files:

`environment.yml` — for local machines and Jupyter-based workflows
`clusterEnvironment.yml` — for HPC or cluster environments

Users can create and activate an environment using either file, for example:

`conda env create -f environment.yml`
`conda activate stanley_env`

or, for cluster usage:

`conda env create -f clusterEnvironment.yml`
`conda activate stanley_env`

Once the environment is active, install STANLEY using one of the methods above.

# Verifying the Installation
Check that STANLEY imports correctly: `python -c "import stanley_cbp; print(stanley_cbp.version)"`
If this prints a version number without errors, the installation succeeded.

# Optional: Using Jupyter Notebooks
If you want to run the Tutorials notebooks, install Jupyter inside your environment: pip install jupyterlab
Then launch Jupyter from inside the Tutorials directory: jupyter lab or jupyter notebook

# What Gets Installed
- The Python package stanley_cbp
- All required static catalogs stored inside stanley_cbp/Databases/
- All package dependencies
No external data downloads are required.

# What You Need to Prepare
Solely the environment. When you run a notebook or script from the Tutorials directory, STANLEY automatically creates and manages all runtime folders. The same can be said for cluster usage so long as you set the `RUN_ROOT` within the bash script. You can expect to see your data written to:

- `LightCurves/`
- `PlanetSearchOutput/`
- `UserGeneratedData/`

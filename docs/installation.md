# Installation
This page explains how to install the Stanley pipeline in a clean and reliable way. The instructions assume basic familiarity with Python environments but do not require advanced setup.

# Requirements
- Python ≥ 3.9
- A working scientific Python stack (NumPy, SciPy, pandas)
- Recommended: a conda or venv environment (a base environment.yml file is included at the top level of the repository)
- Internet connection for installing dependencies

# Creating an Environment (Recommended)
The safest way to install Stanley is inside a fresh environment.
Example using conda:
- Create a new environment (e.g., named stanley_env) with Python 3.9–3.11
- Activate the environment
- Install Stanley inside that environment

# Installing from PyPI (when available)
Use: pip install stanley
This installs the latest published version of Stanley and all required dependencies.

# Installing from a Local Wheel
If you have a locally built wheel (for example, stanley-0.1.X-py3-none-any.whl), install it with: pip install dist/stanley-0.1.X-py3-none-any.whl
Replace 0.1.X with the correct version number.

# Verifying the Installation
Check that Stanley imports correctly: python -c "import stanley; print(stanley.version)"
If this prints a version number without errors, the installation succeeded.

# Optional: Using Jupyter Notebooks
If you want to run the Tutorials notebooks, install Jupyter inside your environment: pip install jupyterlab
Then launch Jupyter from inside the Tutorials directory: jupyter lab or jupyter notebook

# What Gets Installed
- The Python package stanley
- All required static catalogs stored inside stanley/Databases/
- All package dependencies
No external data downloads are required.

# What You Need to Prepare
Nothing. When you run a notebook or script from the Tutorials directory, Stanley automatically creates and manages all runtime folders:

- `LightCurves/`
- `PlanetSearchOutput/`
- `DiagnosticReports/`
- `UserGeneratedData/`

These folders appear in the same directory where you run your notebook or script.
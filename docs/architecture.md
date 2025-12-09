# Architecture & data layout

This page describes how the Stanley package is organized and where it expects
to find and write data on disk. The goal is to make it easy to understand
what lives where and how the pieces talk to each other.

---

## Top level layout

At the top level of the repository you will see:

- `stanley_cbp/`  
  The Python package that implements the pipeline.

- `Tutorials/`  
  Example notebooks that show how to run Stanley on real systems and on
  simple demonstration cases.

- `docs/`  
  User documentation (`index.md`, `installation.md`, `architecture.md`,
  and `tutorials.md`).

- `pyproject.toml`  
  Build and packaging configuration.

- `README.md`, `LICENSE.txt`, `Contributing.md`  
  Front-page description, license, and contribution guidelines.

Other files such as `bump_version.py`, `.gitignore`, `dist/`, and
`stanley_cbp.egg-info/` are support files created during development and
packaging.

---

## Inside the `stanley_cbp` package

The `stanley_cbp/` package is split into logical pieces. File names and exact
boundaries may change over time, but the roles are:

- **Configuration and paths**  
  Small helpers that locate the project base directory and standard
  subfolders (light curves, databases, search output, and so on).  
  Notebooks and scripts call these helpers instead of hard-coding paths.

- **Input / output utilities**  
  Functions to read and write light curves, catalogs, and summary tables.
  These routines handle:
  - Loading mission data (for example TESS light curves)
  - Reading and writing intermediate products
  - Writing human-readable search summaries

- **Detrending**  
  Routines that clean the raw light curves and remove binary variability.
  This stage produces detrended light curves that are ready for planet
  searches.

- **Planet search**  
  The core search engine that scans detrended light curves for
  circumbinary planet signals. This includes:
  - Setting up the grid of trial planet parameters
  - Running the search over all sectors
  - Computing signal detection statistics

- **Analysis and vetting**  
  Tools that interpret candidate signals. Typical tasks include:
  - Basic diagnostics and summary plots
  - Period validation and BJD0 checks
  - Eclipse modeling and secondary eclipse vetting
  - Collecting candidates into summary tables

- **Utility functions**  
  Shared helpers such as time conversions, small math routines,
  logging helpers, and simple plotting functions used across several
  stages of the pipeline.

---

## Data layout on disk

Stanley works inside a single **base directory**. By default this is the
folder that contains your notebook or script, but you can also set it
manually. All input and output folders live under this base directory.

A typical layout looks like:

- `LightCurves/`  
  Raw and preprocessed light curve files. Often split into subfolders by
  target or mission.

- `Databases/`  
  Cached catalogs, parameter tables, or summary information used by the
  pipeline. These files are read by many runs but are not modified often.

- `PlanetSearchOutput/`  
  Outputs from planet searches. Each search usually gets its own
  subfolder (for example by `SearchName`) that contains:
  - Search configuration and logs  
  - SDE maps and diagnostic files  
  - Lists of detected transit times and candidate parameters

- `Injections/` (optional)  
  Input lists and results for injection–recovery tests.

- `Figures/` or `Plots/` (optional)  
  Generated plots, such as phase-folded light curves and SDE maps.

Not every project will use all of these folders, and new folders may be
added, but the pattern is always the same: everything lives under one
base directory, and STANLEY’s path helpers know how to find the standard
subfolders.

---

## How the pieces fit together

A typical run of Stanley follows these steps:

1. **Set the base directory**  
   Your notebook or script selects a base directory. All later steps read
   and write inside this location.

2. **Load light curves and catalogs**  
   I/O utilities read light curve files from `LightCurves/` and any
   necessary catalog information from `Databases/`.

3. **Detrending**  
   The detrending routines read the raw light curves and write detrended
   versions back to disk, usually in a subfolder named by the
   `DetrendingName`.

4. **Planet search**  
   The search engine reads the detrended light curves, runs the search,
   and writes search products under `PlanetSearchOutput/<SearchName>/`.

5. **Analysis and vetting**  
   Analysis tools read the search output, perform checks and modeling, and
   produce:
   - Candidate tables
   - Diagnostic figures
   - Text summaries

6. **Tutorials and scripts**  
   The notebooks in `Tutorials/` are thin wrappers around the package.
   They configure paths and parameters, then call the public functions
   from `stanley_cbp/` so that the same code can be used both in tutorials and
   in research projects.

This structure is intended to keep code, configuration, and data clearly
separated while still making it easy to run Stanley on new systems or on
large samples of binaries.

# Architecture & Data Layout

This page describes how the Stanley package is organized and where it reads and writes data on disk. The goal is a clean, predictable architecture that works identically in:

- local **Jupyter notebook runs**
- **cluster SLURM runs**

Stanley always operates inside a single *base directory*, and all user-generated output lives underneath it.

---

## Top-Level Layout of the Repository

At the top level you will see:

- `stanley_cbp/`  
  The Python package containing all core functionality.

- `Tutorials/`  
  Example notebooks showing full detrending, search, and analysis workflows.

- `docs/`  
  Documentation (`index.md`, `installation.md`, `architecture.md`, `tutorials.md`).

- `pyproject.toml`  
  Build and packaging configuration.

- `README.md`, `LICENSE.txt`
  Front-page documentation, license, and contribution guidelines.

Other support files such as `.gitignore`, `dist/`, and `stanley_cbp.egg-info/` are generated during development and packaging.

---

## Inside the `stanley_cbp` Package

The package is organized into functional modules:

### Configuration & Path Helpers

Helpers that determine the runtime **base directory** and build paths to the standard subfolders:

- `LightCurves/`
- `PlanetSearchOutput/`
- `UserGeneratedData/`

All user-generated data is written *outside* the installed package.

### I/O Utilities

Load mission data, read/write light curves, and save intermediate products or tables.

### Detrending

Removes flux modulation from astrophysical trends. Outputs are written under:

- `LightCurves/Processed/<DetrendingName>/`

### Planet Search

Implements the circumbinary planet search:

- grid construction  
- multi-sector search  
- SDE map generation  
- candidate transit lists  

Outputs are written under:

- `PlanetSearchOutput/<SearchName>/`

### Analysis & Vetting

Produces diagnostic checks, candidate validation, eclipse modeling, and summary documents.  

### Utilities

Shared helpers: time conversions, math routines, plotting helpers, logging, etc.

### Databases (Read-Only)

Static mission catalogs are packaged inside the wheel, under the installed package tree. They are treated as read-only resources and are not modified by runs.

---

## Data Layout on Disk

Stanley runs entirely inside a **base directory**:

- In **local Jupyter runs**, `base_dir()` resolves to the folder that contains your notebook.
- In **cluster runs**, the SLURM script sets an environment variable (for example `STANLEY_WORKDIR`) and `base_dir()` resolves to that directory.

Under this base directory, Stanley creates a consistent data layout:

- `LightCurves/`  
  Raw, detrended, and processed light curves.

- `PlanetSearchOutput/`  
  Search outputs grouped by `<SearchName>/`.

- `UserGeneratedData/`  
  User-generated files such as:
  - manual cut CSVs  
  - injection parameter tables  

This layout is the same whether you are working locally or on a cluster.

---

## Local (Notebook) vs Cluster

### Local Jupyter Notebook Example

If your notebook lives in some folder (for example a `Tutorials/` directory), then:

- `base_dir()` resolves to that folder.
- Stanley writes:

  - `LightCurves/`
  - `PlanetSearchOutput/`
  - `UserGeneratedData/`

  directly underneath that folder.

### Cluster SLURM Example

On the cluster, the run root is defined by the SLURM submission script. The script selects a run directory (for example a `Runs/` folder), sets an environment variable pointing to it (e.g. `RUN_ROOT`), and then changes into that directory before calling STANLEY. An example SLURM submission script (`ExampleBashScript.sh`) is provided in the repository for reference.

In this case:

- `base_dir()` resolves to the run root.
- STANLEY writes:

  - `LightCurves/`
  - `PlanetSearchOutput/`
  - `UserGeneratedData/`

  directly underneath that run root. A `logs/` directory can also be kept at the same level for SLURM and pipeline logs.

The important point is that the *directory structure* is identical in all cases — only the absolute location of the base directory changes.

---

## How Everything Fits Together

A typical workflow looks like:

1. **Set the base directory**  
   - Local: the notebook directory.  
   - Cluster: the directory selected by the SLURM script.

2. **Load light curves / catalogs**  
   Light curves are read from `LightCurves/` and static catalogs are read from the packaged databases.

3. **Detrending**  
   Detrending routines read raw light curves and write outputs under `LightCurves/Processed/<DetrendingName>/`.

4. **Planet Search**  
   The search engine reads the detrended light curves and writes search products under `PlanetSearchOutput/<SearchName>/`.

5. **Analysis & Vetting**  
   Analysis tools read the search outputs, perform checks and modeling, and write tables and figures.

6. **User-Generated Data**  
   Any user choices or metadata (manual cuts, injection definitions, etc.) are stored under `UserGeneratedData/`.

7. **Notebooks and Scripts**  
   The notebooks in `Tutorials/` configure parameters and then call public functions from `stanley_cbp`, so the same code works for tutorials, local analysis, and cluster-scale searches.

This architecture keeps code, configuration, and data clearly separated while preserving a single, predictable layout for all environments.

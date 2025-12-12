# Contributing to Stanley

Thanks for your interest in contributing!  
This project is actively evolving and contributions are welcome.

---

## Development Installation
Developers may create a Conda or Virtual environment within which to contribute:

### Conda environments
`environment.yml` — for local development

`clusterEnvironment.yml` — for HPC or cluster environments

For example:

```
conda env create -f environment.yml
conda activate stanley_env
pip install -e .[dev]
```
Once installed in editable mode, changes to the source code will be reflected immediately without reinstalling.

### Virtual Environment (venv)

```bash
git clone https://github.com/<TKleanthousT>/stanley_cbp.git
cd stanley_cbp
python -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -e .[dev]
```
(On Windows, activate the environment with `.venv\Scripts\activate`).

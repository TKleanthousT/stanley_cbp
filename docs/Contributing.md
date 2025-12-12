# Contributing to Stanley

Thanks for your interest in contributing!  
This project is actively evolving and contributions are welcome.

---

## Development Installation

```bash
git clone https://github.com/<TKleanthousT>/stanley_cbp.git
cd stanley_cbp
python -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -e .[dev]
```
(On Windows, activate the environment with .venv\Scripts\activate.)

## Alternative: Conda environments

Developers may alternatively create a Conda environment using one of the provided environment files:

`environment.yml` — for local development

`clusterEnvironment.yml` — for HPC or cluster environments

Once installed in editable mode, changes to the source code will be reflected immediately without reinstalling.
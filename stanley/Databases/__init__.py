"""
Static database files packaged with STANLEY.

This directory contains CSV tables used throughout the pipeline, including:
- exoplanet archive samples
- TESS and Kepler cut tables
- false positive catalogs
- Villanova orbital data
- filtering and masking helpers

Files in this directory are accessed via:
    importlib.resources.files("stanley.Databases")
"""

# No imports needed — files are accessed via p_databases() or importlib.resources

# Macquarie climate and adaptation case study

This repository contains the code for analyses for the Macquarie climate and adaptation case study, especially the parts that use the HydroBOT toolkit (Holt et al.).

If you want to use scripts available here, clone this repository, and run the `project_setup.bat` file (or use `poetry install` at a terminal to install python dependencies and `renv::restore()` to obtain R dependencies.

## Workflow structure

The basic structure of the workflow is to assess response to the hydrologic scenarios with the [EWR tool](https://pypi.org/project/py-ewr/) for environmental outcomes using [HydroBOT](https://github.com/MDBAuth/HydroBOT) and *GEORGIA FILL IN* for economic. *ANYTHING ELSE? WAS THERE A TOOL FOR ALLOCATION*? These outcomes are then aggregated and synthesized using [HydroBOT](https://github.com/MDBAuth/HydroBOT). All processing is designed to occur either locally or on an HPC running a SLURM job scheduler, with the latter used for computationally expensive steps.

The analyses here rely on having access to climate-informed hydrographs, generated here by Ash Shokri. Scripts in `HPC/file_moving` were used to extract the desired scenarios and move them to the right places for processing. These are then run through the EWR tool using HydroBOT. Due to data size and the need for parallelisation, these are best run on a SLURM HPC cluster, with code to run the EWR part of the analysis in `HPC/run_macq*.R`. These are then aggregated with the notebooks in `HPC/2_*.qmd`. See the [HPC workflow](HPC/WORKFLOW.qmd) for more detail.

Subsequent analysis steps happen in `/Notebooks`, primarily those starting with `3_compare*.qmd`. *GEORGIA SAY SOMETHING MORE HERE*

## Data

The input data is expected to be in a directory outside the repo, and hydrographs from selected scenarios are moved to `project_dir/macq_cut`. This then contains both historical and stochastic scenarios across all climate and management options. Output data (e.g. EWR outputs, aggregated results) is exported to `project_dir` and various subdirectories matching the input scenarios. *GEORGIA WHAT ABOUT ECON ETC- WERE THERE INPUTS*?

## Contact

For more information, contact Galen Holt, g.holt\@deakin.edu.au or Georgia Dwyer g.dwyer\@deakin.edu.au

## Reference

Holt, G. G. Dwyer. HydroBOT: Toolkit For Flow-Dependent outcomes in the Murray-Darling Basin (Version 0.2.0.9018) \[https://github.com/MDBAuth/HydroBOT\]

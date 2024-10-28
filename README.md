# Macquarie climate and adaptation case study

This repository contains the code for analyses for the Macquarie climate and adaptation case study, especially the parts that use the HydroBOT toolkit (Holt et al.).

If you want to use scripts available here, clone this repository, and run the `project_setup.bat` file (or use `poetry install` at a terminal to install python dependencies and `renv::restore()` to obtain R dependencies.

## Workflow structure

The basic structure of the workflow is to assess response to the hydrologic scenarios with the [EWR tool](https://pypi.org/project/py-ewr/) for environmental outcomes using [HydroBOT](https://github.com/MDBAuth/HydroBOT). Water allocation and agricultural/economic outcomes are also read in. These outcomes are then aggregated and synthesized using [HydroBOT](https://github.com/MDBAuth/HydroBOT). All processing is designed to occur either locally or on an HPC running a SLURM job scheduler, with the latter used for computationally expensive steps.

The analyses here rely on having access to climate-informed hydrographs, generated here by Ash Shokri. Scripts in `HPC/file_moving` were used to extract the desired scenarios and move them to the right places for processing. These are then run through the EWR tool using HydroBOT. Due to data size and the need for parallelisation, these are best run on a SLURM HPC cluster, with code to run the EWR part of the analysis in `HPC/run_macq*.R`. These are then aggregated with the notebooks in `HPC/2_*.qmd`. See the [HPC workflow](HPC/WORKFLOW.qmd) for more detail.

Access to water allocation outcomes (generated here by Ash Shokri) and economic outcomes data (generated here by Shokhrukh Jalilov) is also expected. Scripts to tidy and aggregate this data are included in `0_Ash_data_dorting_reliability_resilience.qmd`, `0_Ash_data_sorting.qmd`, and `0_Shok_data_sorting.qmd` located in `/Notebooks/`.

Subsequent analysis steps happen in `/Notebooks/3_compare_for_paper.qmd`. This includes construction of all figures. 

## Data

The input data is expected to be in a directory outside the repo, and hydrographs from selected scenarios are moved to `project_dir/macq_cut`. This then contains both historical and stochastic scenarios across all climate and management options. Output data (e.g. EWR outputs, aggregated results) is exported to `project_dir` and various subdirectories matching the input scenarios. Data for water allocation and economic outcomes are expected to be in `project_dir/module_output/Hydrology` and `project_dir/module_output/Economic`, respectively. 


## Contact

For more information, contact Galen Holt, g.holt\@deakin.edu.au or Georgia Dwyer g.dwyer\@deakin.edu.au

## Reference

Holt, G. G. Dwyer. HydroBOT: Toolkit For Flow-Dependent outcomes in the Murray-Darling Basin (Version 0.2.0.9018) \[https://github.com/MDBAuth/HydroBOT\]

# Macquarie climate and adaptation case study

This repository contains the code for analyses for the Macquarie climate and adaptation case study, especially the parts that use the HydroBOT toolkit.

If you want to use scripts available here, clone this repository, and run the `project_setup.bat` file (or use `poetry install` at a terminal to install python dependencies and `renv::restore()` to obtain R dependencies.

## Workflow structure

The analyses here rely on having access to climate-informed hydrographs, generated here by Ash Shokri. Scripts in `HPC/file_moving` were used to extract the desired scenarios and move them to the right places for processing. These are then run through the EWR tool using HydroBOT. Due to data size and the need for parallelisation, these are best run on a SLURM HPC cluster, with code to run the EWR part of the analysis in `HPC/run_macq*.R`. These are then aggregated with the notebooks in `HPC/2_*.qmd`. See the [HPC workflow](HPC/WORKFLOW.qmd) for more detail.

## Data

The data is expected to be in a directory outside the repo, (set as `datDir` in `directorySet.R`). Currently, the data is all open-source (ANAE layers, soil temp from MODIS/NASA, soil moisture from AWRA-L (Australian Bureau of Meteorology), and some simple spatial layers for the Murray-Darling Basin and RAMSAR wetland sites, with citations in Supplementary Material. As used, the data sits in a directory at CSIRO and is available on request.

## Processing

Most processing is designed to occur either locally or on an HPC running a SLURM job scheduler. The SLURM approach has changed through the life of the project. The most up-to-date approach is in in the [SRA](https://github.com/galenholt/SRA) repository which dispenses with all but one SLURM script. The SLURM scripts in `/SLURM` here are deprecated but kept for reproducibility. The HPC process would likely need to be altered for other HPC environments.

The current flow is to have a method that works both locally or on an HPC. By controlling the HPC parallelisation through foreach and future, and so use foreach loops with %dofuture% and modify the `plan`.

That requires a central control process to spawn subsidiary runs.

In practice, that means we use `any_R.sh` as the control process. It should point to the file to run. But because we use notebooks, we need to `knitr::purl` them to R scripts. So any_R.sh calls `run_r_hpc.R`, which purls a notebook or passes through a script, and then runs it. Then, that script should start a bunch of jobs.

HPCs often have to have some set of packages already installed that need compiled C libraries (especially sf). To access those, we need to add to libPaths, but that doesn't propagate through {future}s if it's done in a script. So, in the .Rprofile, add

```         
if (grepl('^HPCNAME', Sys.info()["nodename"])) {
  renvpaths <- .libPaths()
  .libPaths(new = c(renvpaths,'/path/to/hpc/R/library' ))
}
```

where you get the path to the HPC R library by opening R outside the renv and typing `.libPaths()`.

### Typical run

Once everything's set up, use something like

```         
sbatch any_R.sh run_r_hpc.R "MER_data_processing/notebook_with_processing.qmd"
```

To start a master process in run_r_hpc that then fires off sub-slurms (presumably) in notebook_with_processing.qmd.

## Contact

For more information, contact Galen Holt, g.holt\@deakin.edu.au or Georgia Dwyer g.dwyer\@deakin.edu.au

## Reference

Holt, G. HydroBOT: Toolkit For Flow-Dependent outcomes in the Murray-Darling Basin (Version 0.2.0.9018) \[https://github.com/MDBAuth/HydroBOT\]

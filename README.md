# Readme


- [Overview](#overview)
- [Installation](#installation)
  - [Pinned manuscript environments](#pinned-manuscript-environments)
  - [Current package versions](#current-package-versions)
- [Workflow](#workflow)
  - [Data](#data)
  - [Processing and analysis](#processing-and-analysis)
- [Contact](#contact)
- [References](#references)
- [Project-specific setup](#project-specific-setup)

# Overview

This repository contains the code for analyses for the Macquarie climate
and adaptation case study. It uses the HydroBOT toolkit (Holt and Dwyer
2025; Holt et al. 2025) to analyse hydrograph and economic data for
*Synergies in water availability, the environment, and agricultural
output under climate change and adaptation* (in review)*.*

At the time of submission, this code runs on Windows 11, Ubuntu 20-22,
and SUSE Linux Enterprise Server 15 SP5. Analyses were conducted with
`r R.Version()$version.string`, Python 3.11, and Quarto 1.7. R packages
pinned in /renv.lock, Python packages as in /poetry.lock.

All analysis code (including this documentation) is available at
<https://github.com/galenholt/toolkit-macquarie> and code and data are
also on figshare at <https://doi.org/10.6084/m9.figshare.29345789>.

# Installation

Clone this repository. Then set up environments in one of two ways- as
pinned for the manuscript analysis, or with new versions.

Linux users may need to install C dependencies for spatial processing.
For tested systems, these are

    sudo apt-get -y update

    sudo apt-get -y install libssl-dev libgdal-dev gdal-bin libgeos-dev libproj-dev libsqlite3-dev libudunits2-dev libicu-dev make libglpk-dev libgmp3-dev libxml2-dev pandoc zlib1g-dev

## Pinned manuscript environments

To rebuild the environments as in the paper, set up python and R.

1.  Install [pyenv](https://github.com/pyenv/pyenv) to manage python
    versions. *Use the [windows
    fork](https://github.com/pyenv-win/pyenv-win) on Windows!*. These
    analyses were done with 3.11.

2.  Install [poetry](https://python-poetry.org/docs/) to build python
    environments. After install, set
    `poetry config virtualenvs.in-project true` to get the `.venv` in
    the right place.

3.  Build environment with pinned versions of HydroBOT
    (`r packageVersion('HydroBOT')` and py-ewr
    (`r HydroBOT::get_ewr_version()`). This takes approximately 15
    minutes for a new install, and \<2 if {renv} has already cached the
    R packages.

    - Run the `project_setup.bat` file on Windows, which will install
      the versions of both HydroBOT and its python dependencies (the
      [EWR tool](https://pypi.org/project/py-ewr/)) used for the
      manuscript (py-ewr version 2.1.6).

    - Alternatively, use
      `poetry add git+https://github.com/MDBAuth/EWR_tool.git@8cd3ebc904935ac2bf2df737e6fab28b20e6fa5c`
      at a terminal to install python dependencies and `renv::restore()`

      - This is version 2.1.6 of the EWR tool, modified to read netcdf
        files. That functionality is now built-in to subsequent
        versions, and so releases, e.g. `poetry add py-ewr` will work
        for later analyses.

## Current package versions

To install with the *current* versions of the packages, which are
further ahead than those used for the manuscript, use

``` shell
poetry add py-ewr@latest  
```

and

``` r
renv::install('galenholt/HydroBOT')
```

# Workflow

The basic structure of the workflow is to assess response to the
hydrologic scenarios with the [EWR
tool](https://pypi.org/project/py-ewr/) for environmental outcomes using
[HydroBOT](https://github.com/galenholt/HydroBOT). Water allocation and
agricultural/economic outcomes are also read in. These outcomes are then
aggregated and synthesized using
[HydroBOT](https://github.com/galenholt/HydroBOT). All processing is
designed to occur either locally or on an HPC running a SLURM job
scheduler, with the latter used for computationally expensive steps.

## Data

The input data is expected to be in a directory outside the repo, and
hydrographs from selected scenarios are in `project_dir/hydrographs`.
This then contains both historical and stochastic scenarios across all
climate and management options. Output data (e.g. EWR outputs,
aggregated results) is exported to `project_dir` and various
subdirectories matching the input scenarios. Data for water allocation
and economic outcomes are expected to be in
`project_dir/module_output/Hydrology` and
`project_dir/module_output/Economic`, respectively.

As supplemental information (at
<https://doi.org/10.6084/m9.figshare.29345789>), we provide three
datasets-

1.  `input_data`: input data used for all processing
    - Process as in *Processing and analysis,* below
2.  `demo`: a small subset of the input data used to check processing
    works
    - See [processing_demonstration -
      Notebooks/processing_demonstration.qmd](Notebooks/processing_demonstration.qmd).
3.  `paper_input` the output of the computationally-intensive EWR and
    aggregation processing, ready to make figures
    - Use the [main analysis notebook -
      Notebooks/3_compare_for_paper.qmd](Notebooks/3_compare_for_paper.qmd)

      - If newly processed data *also* exists, do this in a new
        directory or use the `params` in header to avoid overwriting
        output.

## Processing and analysis

To produce the analyses for the manuscript, we follow these steps. We
assume steps 1 and 2 are run on an HPC for speed and step 3 is local,
though all will work in either. All scripts are available at
<https://github.com/galenholt/toolkit-macquarie> and
<https://doi.org/10.6084/m9.figshare.29345789>.

1.  Run the EWR tool (via HydroBOT) over the various hydrographs. These
    are broken up to stabilise processing in parallel on an HPC. See
    [HPC workflow](HPC/WORKFLOW.qmd) for more detail.
    1.  /HPC/run_macq_stoch.R
    2.  /HPC/run_macq_hist.R
    3.  /HPC/run_macq_EWRtarget.R
2.  Aggregate the EWR outputs to ecological response using HydroBOT
    1.  /HPC/2_aggregate_HPC.qmd
    2.  /HPC/2_stochastic_stats.qmd
    3.  /HPC/2_baseline_to_historic.qmd
3.  Prepare figures and analyses for manuscript
    1.  /Notebooks/3_compare_for_paper.qmd

# Contact

For more information, contact Galen Holt, g.holt@deakin.edu.au or
Georgia Dwyer g.dwyer@deakin.edu.au

# References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-Holt_HydroBOT_Toolkit_For" class="csl-entry">

Holt, Galen, and Georgia Dwyer. 2025. “<span class="nocase">HydroBOT:
Toolkit For Flow-Dependent outcomes in the Murray-Darling Basin</span>.”
<https://galenholt.github.io/HydroBOT/>.

</div>

<div id="ref-holt2025" class="csl-entry">

Holt, Galen, Georgia Dwyer, David Robertson, Martin Job, and Rebecca E.
Lester. 2025. “HydroBOT: An Integrated Toolkit for Assessment of
Hydrology-Dependent Outcomes.” *Environmental Modelling & Software*,
June, 106579. <https://doi.org/10.1016/j.envsoft.2025.106579>.

</div>

</div>

# Project-specific setup

The data provided on submission is in a ready-to-analyse state. It was
generated in other systems and requires some selection and moving for
access. The relevant scripts are as follows:

The analyses here rely on having access to climate-informed hydrographs,
generated by Ash Shokri. Only a subset of those hydrographs are used
here; scripts in `HPC/file_moving` were used to extract the desired
scenarios and move them to the right places for processing. These are
then run through the EWR tool using HydroBOT. Due to data size and the
need for parallelisation, these are best run on a SLURM HPC cluster,
with code to run the EWR part of the analysis in `HPC/run_macq*.R`.
These are then aggregated with the notebooks in `HPC/2_*.qmd`. See the
[HPC workflow](HPC/WORKFLOW.qmd) for more detail and specific SLURM
commands and batching scripts that work well on petrichor.

Access to water allocation outcomes (generated here by Ash Shokri) and
economic outcomes data (generated here by Shokhrukh Jalilov) is also
required. Scripts to tidy and aggregate this data are included in
`0_Ash_data_sorting_reliability_resilience.qmd`,
`0_Ash_data_sorting.qmd`, and `0_Shok_data_sorting.qmd` located in
`/Notebooks/data_prep`.

Analysis steps happen in `/Notebooks/3_compare_for_paper.qmd`. This
includes construction of all figures.

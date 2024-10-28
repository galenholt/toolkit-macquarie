library(HydroBOT)
library(sf)
library(dplyr)
library(ggplot2)

# Outer directory for project data
# the templates
# project_dir = file.path('template_data/netcdfs')

# The data on Bowen (A very small set to make sure we have access)
project_dir = file.path('/datasets/work/ev-ca-macq/work/hol436/ash_cut/stochastic/MACQ_CC_EFR/licvolfactor_1_0')
# Hydrographs (expected to exist already)
# hydro_dir = file.path(project_dir, 'hydrographs')
# This is a bit contrived to test.
hydro_dir = file.path(project_dir, 'r1_0_e1_0')
# It works though. Now the trick will be setting up the parallel system

# Generated data
# EWR outputs (will be created here in controller, read from here in aggregator)
ewr_results <- file.path(project_dir, 'module_output', 'EWR')

future::plan(future::sequential)

# run the ewr tool
ewr_out <- prep_run_save_ewrs(hydro_dir = hydro_dir,
                              output_parent_dir = project_dir,
                              model_format = 'IQQM - netcdf',
                              outputType = outputType,
                              returnType = returnType,
                              rparallel = TRUE)

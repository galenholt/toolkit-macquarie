# hpc test script

# renvpaths <- .libPaths()
# .libPaths(new = c(renvpaths,'/ceph-g/opt/R/4.3/lib/R/library' ))
# Sys.setenv('R_LIBS' = '/ceph-g/opt/R/4.3/lib/R/library')

library(HydroBOT)
library(sf)
library(dplyr)
library(ggplot2)
library(future.batchtools)
library(furrr)

# I'll want to bump up the tasks per node here, but this should work for time-checking
plan(list(tweak(batchtools_slurm,
                workers = 2,
                template = "HPC/batchtools.slurm.tmpl",
                resources = list(time = 60,
                                 ntasks.per.node = 1, # should be 64 or so, really. Though there's an argument for using somethign intermediate like 30 or 40.
                                 mem = '4GB',
                                 job.name = 'WERPTEST')),
          multicore))

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
ewr_results <- file.path('/datasets/work/ev-ca-macq/work/hol436/ash_cut/', 'module_output', 'EWR')

outputType <- list('summary', 'yearly')
returnType <- list('none') # list('summary', 'yearly')

# run the ewr tool
ewr_out <- prep_run_save_ewrs(hydro_dir = hydro_dir,
                              output_parent_dir = ewr_results,
                              model_format = 'IQQM - netcdf',
                              outputType = outputType,
                              returnType = returnType,
                              rparallel = TRUE)

# hpc test script

# renvpaths <- .libPaths()
# .libPaths(new = c(renvpaths,'/ceph-g/opt/R/4.3/lib/R/library' ))
# Sys.setenv('R_LIBS' = '/ceph-g/opt/R/4.3/lib/R/library')

library(werptoolkitr)
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

# outputs of aggregator. There may be multiple modules
agg_results <- file.path(project_dir, 'aggregator_output')

outputType <- list('summary', 'yearly')
returnType <- list('none') # list('summary', 'yearly')

sdl_clip <- sdl_units |>
  filter(SWSDLName %in% c("Lachlan", "Murrumbidgee", "Macquarie–Castlereagh"))

aggseq <- list(ewr_code = c('ewr_code_timing', 'ewr_code'),
               planning_unit = planning_units,
               env_obj =  c('ewr_code', "env_obj"),
               sdl_units = sdl_clip,
               Specific_goal = c('env_obj', "Specific_goal"),
               Objective = c('Specific_goal', 'Objective'),
               mdb = basin,
               target_5_year_2024 = c('Objective', 'target_5_year_2024'))


funseq <- list('CompensatingFactor',
               'ArithmeticMean',
               'ArithmeticMean',
               'SpatialWeightedMean',
               'ArithmeticMean',
               'ArithmeticMean',
               'SpatialWeightedMean',
               'ArithmeticMean')


future::plan(future::sequential)

# run the ewr tool
ewr_out <- prep_run_save_ewrs(hydro_dir = hydro_dir,
                              output_parent_dir = project_dir,
                              model_format = 'IQQM - netcdf',
                              outputType = outputType,
                              returnType = returnType,
                              rparallel = FALSE)

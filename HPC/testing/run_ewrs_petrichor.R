# hpc test script

# renvpaths <- .libPaths()
# .libPaths(new = c(renvpaths,'/ceph-g/opt/R/4.3/lib/R/library' ))
# Sys.setenv('R_LIBS' = '/ceph-g/opt/R/4.3/lib/R/library')

library(werptoolkitr)
library(sf)
library(dplyr)
library(ggplot2)
library(future.batchtools)
library(furrr)

# Outer directory for project data
# the templates
# project_dir = file.path('template_data/netcdfs')

# The data on Bowen (A very small set to make sure we have access)
# project_dir = file.path('/datasets/work/ev-ca-macq/work/hol436/ash_cut/stochastic/MACQ_CC_EFR/licvolfactor_1_0')
project_dir <- file.path('/datasets/work/ev-ca-macq/work/hol436/ash_cut')
# Hydrographs (expected to exist already)
# hydro_dir = file.path(project_dir, 'hydrographs')
# This is a bit contrived to test.
# hydro_dir = file.path(project_dir, 'r1_0_e1_0')
# Now I want to get a list of hydro_dirs that each have a reasonable number of sims in them.
# Let's maybe do it separately for historical and stochastic
stoch_dirs <- list.dirs(file.path(project_dir, 'stochastic'), recursive = TRUE)
# Now, I think I want to choose the ones that *end* with a climate specification. IE not their parents, and not the stochastic iterations
# no_mgmt = ['licvolfactor_1_0']
# with_mgmt = ['licvolfactor_0_5', 'licvolfactor_0_7', 'licvolfactor_0_9', 'licvolfactor_1_0', 'licvolfactor_1_1', 'licvolfactor_1_3', 'licvolfactor_1_5']
# climpattern = ['r0_8_e1_0', 'r0_8_e1_07', 'r1_0_e1_0', 'r1_0_e1_07', 'r1_2_e1_0', 'r1_2_e1_07']
stoch_climdirs <- grepl('r[0-9]_[0-9]_e1_[0-9]{1,2}$', stoch_dirs)
# It works though. Now the trick will be setting up the parallel system
stoch_parents <- stoch_dirs[stoch_climdirs]
# Generated data

stoch_subdirs <- gsub(project_dir, '', stoch_parents)
stoch_subdirs <- gsub('^/', '', stoch_subdirs)

outputType <- list('summary', 'yearly')
returnType <- list('none') # list('summary', 'yearly')

# run the ewr tool

# I'll want to bump up the tasks per node here, but this should work for time-checking
# For the test, 4x2 (838 - but only one of the 8 tasks took that long for some reason) should give each scenario a cpu.
# Should also time-test 4x1 (765), 4x4 (437)? 2x4 (850)?
plan(list(tweak(batchtools_slurm,
                workers = 4, # default is 100, maybe just use that? Or length(stoch_parents)? though we can play around once we have the full set.
                template = "HPC/batchtools.slurm.tmpl",
                resources = list(time = 60, # Can cut way down. Seems to take 7.5 minutes for a single run. Will need to calculate how many each cpu will do, but if it's one, 15 is likely enough.
                                 ntasks.per.node = 2, # should be 64 or so, really. Though there's an argument for using somethign intermediate like 30 or 40.
                                 mem.per.cpu = '4GB',
                                 job.name = 'WERPTEST')),
          multicore))

# The internal parallel uses furrr. Here, we want to parallel over two lists by index (stoch_parents and stoch_subdirs). Will that be easier with a foreach?
# furrr::future_map2 should work
ewr_out <- furrr::future_map2(stoch_parents, stoch_subdirs, \(x, y) 
    prep_run_save_ewrs(hydro_dir = x,
                              output_parent_dir = project_dir,
                              output_subdir = y,
                              model_format = 'IQQM - netcdf',
                              outputType = outputType,
                              returnType = returnType,
                              rparallel = TRUE)
)

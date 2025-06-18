# Script to run EWR tool for stochastic data on petrichor

# any_R.R needs to ask for > 2 hours. It will run in 10 minutes, but sits in teh queue a long time because of the cpus I request. 2 hours just *barely* finished, so for safety say 6 or something- any_r doesn't use many resources, so that shoudl be fine.

library(HydroBOT)
library(sf)
library(dplyr)
library(ggplot2)
library(future.batchtools)
library(furrr)

# useful info
# no_mgmt = ['licvolfactor_1_0']
# with_mgmt = ['licvolfactor_0_5', 'licvolfactor_0_7', 'licvolfactor_0_9', 'licvolfactor_1_0', 'licvolfactor_1_1', 'licvolfactor_1_3', 'licvolfactor_1_5']
# climpattern = ['r0_8_e1_0', 'r0_8_e1_07', 'r1_0_e1_0', 'r1_0_e1_07', 'r1_2_e1_0', 'r1_2_e1_07']

# Outer directory for project data
source('R/paths.R')

# Hydrographs (expected to exist already)
# To set up node-loops, we want a list of hydro_dirs that each have a reasonable number of sims in them.
# It's annoying, but I'll set up different scripts for stochastic and historical. That'll be the easiest way to load-balance and keep output directories the same.s

# The directory crawling is SLOW, so cache it.
## Stochastic
if (!file.exists('HPC/stoch_dirs.rds')) {
    stoch_dirs <- list.dirs(file.path(project_dir, 'hydrographs/stochastic'), recursive = TRUE)
    saveRDS(object = stoch_dirs, file = 'HPC/stoch_dirs.rds')
} else {
    stoch_dirs = readRDS('HPC/stoch_dirs.rds')
}

# For stochastic, I think I want to choose the ones that *end* with a climate specification. IE not their parents, and not the stochastic iterations
stoch_climdirs <- grepl('r[0-9]_[0-9]_e1_[0-9]{1,2}$', stoch_dirs)
stoch_parents <- stoch_dirs[stoch_climdirs]
# Those will be the hydro_dirs, each with 76 scenarios inside
# Then we want to make the outputs work, so put them in subdirs with the same structure
stoch_subdirs <- gsub(project_dir, '', stoch_parents)
stoch_subdirs <- gsub('^/', '', stoch_subdirs)

outputType <- list('summary', 'yearly')
returnType <- list('none') # list('summary', 'yearly')

# run the ewr tool

# set up different plans depending on location

if (is_slurm) {
  # The values here are after testing timings
  plan(list(tweak(batchtools_slurm,
                  # workers = 100, # default is 100, seems to work. It'll only be 60 anyway, since that's the length.
                  template = "HPC/batchtools.slurm.tmpl",
                  resources = list(time = 30, # Seems to take 7.5 minutes for a single run. Will need to calculate how many each cpu will do, but if it's one, 15 is likely enough. 30 should be more than enough for running two back to back, I think.
                                   ntasks.per.node = 64, # 64 seems to work best even though nodes have 76 and 38 is half of 76, so would theoretically be faster at getting free space. We'll need to double the time no matter what, so might as well eat less of the nodes
                                   mem.per.cpu = '4GB', # 'mem' alone is for the whole node, so this is safer
                                   job.name = 'macstoch')),
            multicore))
} else {
  # could be multisession, but sequential better for debug
  plan(sequential)
}


# The internal parallel uses furrr. Here, we want to parallel over two lists by index (stoch_parents and stoch_subdirs). Will that be easier with a foreach?
# furrr::future_map2 should work
ewr_out <- furrr::future_map2(stoch_parents, stoch_subdirs, \(x, y)
    prep_run_save_ewrs(hydro_dir = x,
                              output_parent_dir = project_dir,
                              output_subdir = y,
                              file_search = 'cutflows', #Otherwise we pick up the h2o_table
                              model_format = 'IQQM - netcdf',
                              outputType = outputType,
                              returnType = returnType,
                              fill_missing = TRUE,
                              rparallel = TRUE),
    .options = furrr_options(seed = TRUE)
)

final_files <- list.files(file.path(project_dir, 'module_output',  'EWR', 'hydrographs', 'stochastic'), pattern = 'yearly_cutflows.csv', recursive = TRUE)

cat('\n## Job finished\n')
cat('\n Expected to run \n')
print(length(stoch_parents)*76)
cat('\n scenarios , actually created \n')
  print(length(final_files))
  cat('\n , outputs \n')
cat("\n")

# Use check_missing_runs to double-check it works.

# Loop that just like the main run
missing_runs <- furrr::future_map2(stoch_parents, stoch_subdirs, \(x, y)
        check_missing_runs(hydro_dir = x,
                              output_parent_dir = project_dir,
                              output_subdir = y,
                              file_search = 'cutflows', #Otherwise we pick up the h2o_table
                              model_format = 'IQQM - netcdf',
                              outputType = outputType)
)

cat('\n## If there are missing runs, they are\n')
print(unlist(missing_runs))
cat("\n")

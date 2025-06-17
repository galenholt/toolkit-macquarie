# Script to run EWR tool for stochastic data on petrichor

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
# if (!file.exists('HPC/stoch_dirs.rds')) {
#     stoch_dirs <- list.dirs(file.path(project_dir, 'stochastic'), recursive = TRUE)
#     saveRDS(object = stoch_dirs, file = 'HPC/stoch_dirs.rds')
# } else {
#     stoch_dirs = readRDS('HPC/stoch_dirs.rds')
# }

# Historical
if (!file.exists('HPC/hist_dirs.rds')) {
    hist_dirs <- list.dirs(file.path(project_dir, 'hydrographs/historical'), recursive = TRUE)
    saveRDS(object = hist_dirs, file = 'HPC/hist_dirs.rds')
} else {
    hist_dirs = readRDS('HPC/hist_dirs.rds')
}


# For stochastic, I think I want to choose the ones that *end* with a climate specification. IE not their parents, and not the stochastic iterations
# stoch_climdirs <- grepl('r[0-9]_[0-9]_e1_[0-9]{1,2}$', stoch_dirs)
# stoch_parents <- stoch_dirs[stoch_climdirs]
# # Those will be the hydro_dirs, each with 76 scenarios inside
# # Then we want to make the outputs work, so put them in subdirs with the same structure
# stoch_subdirs <- gsub(project_dir, '', stoch_parents)
# stoch_subdirs <- gsub('^/', '', stoch_subdirs)

## Historical
# In an ideal world, I would choose the ones that *end* with a licvol specification. IE not their parents, and not the stochastic iterations. That'd yeild 18 per.
# But that would make the output structure differ without significant monkeying around. So I think perhaps the easiest thing to do is just do the same thing as the stochastic, but only ask for 1-2 cpus. That'll be the easiest to match up.
hist_climdirs <- grepl('r[0-9]_[0-9]_e1_[0-9]{1,2}$', hist_dirs)
hist_parents <- hist_dirs[hist_climdirs]
# Those will be the hydro_dirs, each with 76 scenarios inside
# Then we want to make the outputs work, so put them in subdirs with the same structure
hist_subdirs <- gsub(project_dir, '', hist_parents)
hist_subdirs <- gsub('^/', '', hist_subdirs)

outputType <- list('summary', 'yearly')
returnType <- list('none') # list('summary', 'yearly')

# run the ewr tool

# I'll want to bump up the tasks per node here, but this should work for time-checking
# For the test, 4x2 (838) should give each scenario a cpu.
# Should also time-test 4x1, 4x4? 2x4?
plan(list(tweak(batchtools_slurm,
                # workers = 4, # default is 100, maybe just use that? It'll only be 60 anyway, since that's the length. Or length(stoch_parents)? though we can play around once we have the full set.
                template = "HPC/batchtools.slurm.tmpl",
                resources = list(time = 30, # Can cut way down. Seems to take 7.5 minutes for a single run. Will need to calculate how many each cpu will do, but if it's one, 15 is likely enough. 30 should be more than enough for running two back to back, I think.
                                 ntasks.per.node = 2, # could probably get by with 1, but might as well ask for 2?
                                 mem.per.cpu = '4GB', # I think 'mem' alone is for the whole node, so this is safer
                                 job.name = 'machist')),
          multicore))

# The internal parallel uses furrr. Here, we want to parallel over two lists by index (hist_parents and hist_subdirs). Will that be easier with a foreach?
# furrr::future_map2 should work
ewr_out <- furrr::future_map2(hist_parents, hist_subdirs, \(x, y)
    prep_run_save_ewrs(hydro_dir = x,
                              output_parent_dir = project_dir,
                              output_subdir = y,
                              file_search = 'cutflows', #Otherwise we pick up the h2o_table
                              model_format = 'IQQM - netcdf',
                              outputType = outputType,
                              returnType = returnType,
                              rparallel = TRUE)
)

final_files <- list.files(file.path(project_dir, 'module_output', 'EWR', 'hydrographs', 'historical'), pattern = 'summary.csv', recursive = TRUE)

cat('\n## Job finished\n')
cat('\n Expected to run \n')
print(length(hist_parents))
cat('\n scenarios , actually created \n')
  print(length(final_files))
  cat('\n , outputs \n')
cat("\n")

# Loop check_missing_runs just like hte main prep_run_save
missing_runs <- furrr::future_map2(hist_parents, hist_subdirs, \(x, y)
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

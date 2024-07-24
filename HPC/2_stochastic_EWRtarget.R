## -----------------------------------------------------------------------------
library(werptoolkitr)
library(sf)
library(future.batchtools)
library(furrr)


## -----------------------------------------------------------------------------
source('R/read_in_aggs.R')
source('R/paths.R')
source('R/agg_variables.R')


## -----------------------------------------------------------------------------
#| eval: false

## infile <- 'HPC/2_stochastic_EWRtarget.qmd'
## 
## rfile <- stringr::str_replace(infile, '.qmd', '.R')
## 
## knitr::purl(input = infile, output = rfile)
## 


## -----------------------------------------------------------------------------
if (Sys.info()['user'] == 'hol436') {
  plan(list(tweak(batchtools_slurm,
                  workers = 1, # I assume it'll grab 4, since that's the length of the futurelist vectors
                  template = "HPC/batchtools.slurm.tmpl",
                  resources = list(time = 15, # Can cut way down probably. 
                                   ntasks.per.node = 30, 
                                   mem.per.cpu = '4GB', # I think 'mem' alone is for the whole node, so this is safer
                                   job.name = 'macagg')),
            multicore))
} else {
  plan(multisession)
}


## -----------------------------------------------------------------------------
# Get all the EWR dir paths should I save this like i did with the gauges? 
# Wouldn't locally, but it's really slow on petrichor.

if (!file.exists('HPC/inner_dirs_agg_ewrtarget.rds')) {
    inner_dirs <- list.dirs(
  agg_dir, recursive = TRUE
  )
      inner_dirs <- inner_dirs[grepl('exp11', inner_dirs)] 
    saveRDS(object = inner_dirs, file = 'HPC/inner_dirs_agg_ewrtarget.rds')
} else {
    inner_dirs = readRDS('HPC/inner_dirs_agg_ewrtarget.rds')
}


inner_climdirs <- grepl('r[0-9]_[0-9]_e1_[0-9]{1,2}$', inner_dirs)
inner_parents <- inner_dirs[inner_climdirs]
# Those will be the hydro_dirs, each with 76 scenarios inside
# Then we want to make the outputs work, so put them in subdirs with the same structure
inner_subdirs <- gsub(agg_dir, '', inner_parents)
inner_subdirs <- gsub('^/', '', inner_subdirs)


## -----------------------------------------------------------------------------
# looplists for the aggregations
spellframes <- list('sdl_ewr_spells', 'sdl_target_spells')
retainedframes <- list(retained_sEs, retained_sTs)
retained_vuln <- list(retained_vE, retained_vT)


# Group by everythign except the data and the replicate. Have to drop 'scenario' too, because it's unique
param_groups <- c('Data', 'Mk', 'licvolfactor', 'Rainfall', 'Evapotranspiration', 'aggregation')
dimgroups <- c('ewr_code', 'target', 'date', 'polyID', 'SWSDLID', 'SWSDLName', 'StateID', 'geometry')

groups <- c(param_groups, dimgroups)



## -----------------------------------------------------------------------------
# # These are matched indices from 1:2
# aggin <- spellframes[[typeit]]
# retained_in <- retainedframes[[typeit]]
# retained_vuln <- retained_vuln[[typeit]]

looplist <- list(aggin = spellframes, 
                 retained_in = retainedframes,
                 retained_vuln = retained_vuln,
                 inner_subdirs = list(inner_subdirs, inner_subdirs))





## -----------------------------------------------------------------------------
calc_vulnerability <- function(subdir, aggin, retained_in, retained_vuln) {
  onespells <- read_in_aggs(project_dir = project_dir,
                            data_path = file.path(subdir, aggin),
                            lastagg = 'sdl_units',
                            retain_cols = retained_in,
                            max_handling = 'remove')
  
  vulnerability <- onespells |> 
    general_aggregate(groupers = groups, 
                      aggCols = tidyselect::ends_with(c('ewr_achieved',
                                                        'event_years')),
                      funlist = c('ArithmeticMean', 'Max', 'Variance'),
                      prefix = 'replicates_',
                      failmissing = FALSE) # lets us have a full set of possible groupers
  
  vuln <- select_sequence(vulnerability, 
                          lastagg = 'replicates', 
                          retain_cols = retained_vuln)
  # all(retained_vuln %in% names(vuln))
  
  # change the aggregation name
  vuln$aggregation <- gsub('_spells', '_vulnerability', vuln$aggregation)
  
  outdir <- file.path(project_dir, 'aggregated', 
                      subdir, gsub('_spells', '_vulnerability', aggin))
  
  if (!dir.exists(outdir)) {
    dir.create(outdir)
  }
  
  saveRDS(vuln, file = file.path(outdir, 'achievement_aggregated.rds'))
  
}

dirloop <- function(aggin, retained_in, retained_vuln, inner_subdirs) {
  furrr::future_map(inner_subdirs, 
                    \(x) calc_vulnerability(x, aggin, 
                                            retained_in, retained_vuln))
  
}


## -----------------------------------------------------------------------------
# If I run this locally, I don't want to parallel over this outer layer
# and kind of don't on the HPC either.
if (Sys.info()['user'] == 'hol436') {
  system.time(aggloop <- furrr::future_pmap(looplist, dirloop))
} else {
  system.time(aggloop <- purrr::pmap(looplist, dirloop))
}



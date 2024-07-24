## -----------------------------------------------------------------------------
library(werptoolkitr)
library(sf)
library(future.batchtools)
library(furrr)


## -----------------------------------------------------------------------------
# aggregation read-in funciton
source('R/read_in_aggs.R')


## -----------------------------------------------------------------------------
# tired of writing the whole thing out
source('R/paths.R')
source('R/agg_variables.R')


## -----------------------------------------------------------------------------
# Get all the EWR dir paths should I save this like i did with the gauges? 
# Wouldn't locally, but it's really slow on petrichor.

if (!file.exists('HPC/inner_dirs_agg.rds')) {
    inner_dirs <- list.dirs(
  agg_dir, recursive = TRUE
  )
    saveRDS(object = inner_dirs, file = 'HPC/inner_dirs_agg.rds')
} else {
    inner_dirs = readRDS('HPC/inner_dirs_agg.rds')
}


inner_climdirs <- grepl('r[0-9]_[0-9]_e1_[0-9]{1,2}$', inner_dirs)
inner_parents <- inner_dirs[inner_climdirs]
# Those will be the hydro_dirs, each with 76 scenarios inside
# Then we want to make the outputs work, so put them in subdirs with the same structure
inner_subdirs <- gsub(agg_dir, '', inner_parents)
inner_subdirs <- gsub('^/', '', inner_subdirs)


## -----------------------------------------------------------------------------
# Group by everythign except the data and the replicate. Have to drop 'scenario' too, because it's unique
param_groups <- c('Data', 'Mk', 'licvolfactor', 'Rainfall', 'Evapotranspiration', 'aggregation', 'replicate')
dimgroups <- c('ewr_code', 'target', 'date', 'polyID', 'SWSDLID', 'SWSDLName', 'StateID', 'geometry')

groups <- c(param_groups, dimgroups)


## -----------------------------------------------------------------------------
aggnames <- c('sdl_ewr_spells', 'sdl_target_spells')



## -----------------------------------------------------------------------------
baseline_one <- function(aggpath, aggname) {
  
  # add the _target or _ewr type
  thisfile <- file.path(aggpath, aggname)
  
  # Get which Mark to use
  mark <- stringr::str_extract(aggpath, "MACQ[^/]+")
  
  # the path to the reference file
  match_historic <- file.path('historical', mark, 'licvolfactor_1_0', 'r1_0_e1_0', aggname)
  
  # catch the edge case of the baseline df
  is_baseline <- thisfile == match_historic
  
  if (is_baseline) {
    thispair <- thisfile
  } else {
    thispair <- c(thisfile, match_historic)
  }
  
  # Read in the baseline and the target
  read1 <- read_in_aggs(project_dir = project_dir,
                        info_list = aggregation_info,
                        aggname = aggname,
                        data_path = thispair,
                        max_handling = 'remove')
  
  # make referencing easier
  reflev <- paste0(match_historic, '/0')
  
  # Do the baseline
  based <- baseline_compare(val_df = read1,
                            compare_col = 'scenario',
                            base_lev = reflev,
                            group_cols = dimgroups,
                            comp_fun = relative,
                            values_col = 'ewr_achieved',
                            failmissing = FALSE)
  
  
  # Remove reference data unless this *is* the reference
  if (!is_baseline) {
    based <- based |> 
      dplyr::filter(scenario != reflev)
  }
  
  # change the aggregation name
  based$aggregation <- gsub('_spells', '_baseline', based$aggregation)
  
  # set up saving
  outdir <- file.path(project_dir, 'aggregated', 
                      aggpath, gsub('_spells', '_baseline', aggname))
  
  if (!dir.exists(outdir)) {
    dir.create(outdir)
  }
  
  saveRDS(based, file = file.path(outdir, 'achievement_aggregated.rds'))
  
  return(NULL)
  
}


## -----------------------------------------------------------------------------
# parallel loop over inner_subdirs
looplist <- list(aggpath = rep(inner_subdirs, length(aggnames)),
                 aggname = rep(aggnames, each = length(inner_subdirs)))

system.time(aggloop <- furrr::future_pmap(looplist, baseline_one))


